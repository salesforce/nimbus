//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.annotation.SuppressLint
import android.webkit.JavascriptInterface
import android.webkit.WebView
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.concurrent.ConcurrentHashMap

@SuppressLint("SetJavaScriptEnabled", "JavascriptInterface")
class NimbusBridge {

    companion object {
        private const val BRIDGE_NAME = "_nimbus"
    }

    private var bridgeWebView: WebView? = null
    private val binders = mutableListOf<NimbusBinder>()

    /**
     * Adds a [NimbusBinder] to the bridge.
     */
    fun add(vararg binder: NimbusBinder) {
        binders.addAll(binder)
    }

    /**
     * Attaches the bridge to the provided [webView], initializing each extension and loading the
     * [appUrl].
     */
    fun attach(webView: WebView) {
        bridgeWebView = webView
        if (!webView.settings.javaScriptEnabled) {
            webView.settings.javaScriptEnabled = true
        }
        webView.addJavascriptInterface(this, BRIDGE_NAME)
        initialize(webView, binders)
    }

    fun loadUrl(appUrl: String) {
        bridgeWebView?.loadUrl(appUrl)
    }

    /**
     * Detaches the bridge performing any necessary cleanup.
     */
    fun detach() {
        bridgeWebView?.let { webView ->
            webView.removeJavascriptInterface(BRIDGE_NAME)
            cleanup(webView, binders)
        }
        binders.clear()
        bridgeWebView = null
    }

    fun invoke(
        functionName: String,
        args: Array<JSONSerializable?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)
    ) {
        val promiseId = UUID.randomUUID().toString()
        promises[promiseId] = callback

        val jsonArray = JSONArray()
        args.forEachIndexed { _, jsonSerializable ->
            val asPrimitive = jsonSerializable as? PrimitiveJSONSerializable
            if (asPrimitive != null) {
                jsonArray.put(asPrimitive.value)
            } else {
              jsonArray.put(if (jsonSerializable == null) JSONObject.NULL
              else JSONObject(jsonSerializable.stringify()))
            }
        }
        val jsonString = jsonArray.toString()
        val script = """
        {
            let args = $jsonString;
            let promise = undefined;
            try {
                // TODO: fortify this against injection
                promise = Promise.resolve($functionName(...args));
            } catch (error) {
                promise = Promise.reject(error);
            }
            promise.then((value) => {
                _nimbus.resolvePromise("$promiseId", JSON.stringify({value: value}));
            }).catch((err) => {
                _nimbus.rejectPromise("$promiseId", err.toString());
            });
        }
        null;
        """.trimIndent()

        bridgeWebView?.handler?.post {
            bridgeWebView?.evaluateJavascript(script, null)
        }
    }

    @Suppress("unused")
    @JavascriptInterface
    fun resolvePromise(promiseId: String, json: String?) {
        var value: Any?
        json.let {
            value = JSONObject(it).get("value")
        }
        val promise = promises.remove(promiseId)
        promise?.let {
            it(null, value)
        }
    }

    @Suppress("unused")
    @JavascriptInterface
    fun rejectPromise(promiseId: String, error: String) {
        val promise = promises.remove(promiseId)
        promise?.let {
            it(error, null)
        }
    }

    @Suppress("unused")
    @JavascriptInterface
    fun pageUnloaded() {
        val canceledPromises = ConcurrentHashMap(promises)
        promises.clear()
        for (promise in canceledPromises.values) {
            promise("ERROR_PAGE_UNLOADED", null)
        }
    }

    private val promises: ConcurrentHashMap<String, Function2<String?, Any?, Unit>> = ConcurrentHashMap()

    /**
     * Creates and returns a Callback object that can be passed as an argument to
     * a subsequent JavascriptInterface bound method.
     */
    @Suppress("unused")
    @JavascriptInterface
    fun makeCallback(callbackId: String): Callback? {
        return bridgeWebView?.let { return Callback(it, callbackId) }
    }

    /**
     * Return the names of all connected extensions so they can be processed by the
     * JavaScript runtime code.
     */
    @Suppress("unused")
    @JavascriptInterface
    fun nativeExtensionNames(): String {
        val names = binders.map { it.getExtensionName() }
        val result = JSONArray(names)
        return result.toString()
    }

    private fun initialize(webView: WebView, binders: Collection<NimbusBinder>) {
        binders.forEach { binder ->

            // customize web view if needed
            binder.getExtension().customize(webView)

            // bind web view to binder
            binder.setWebView(webView)

            // add the javascript interface for the binder
            val extensionName = binder.getExtensionName()
            webView.addJavascriptInterface(binder, "_$extensionName")
        }
    }

    protected fun finalize() {
        promises.values.forEach { it.invoke("Canceled", null) }
        promises.clear()
    }

    private fun cleanup(webView: WebView, binders: Collection<NimbusBinder>) {
        binders.forEach { binder ->

            // cleanup web view if needed
            binder.getExtension().cleanup(webView)

            // unbind web view from binder
            binder.setWebView(null)

            // remove the javascript interface for the binder
            val extensionName = binder.getExtensionName()
            webView.removeJavascriptInterface("_$extensionName")
        }
    }
}
