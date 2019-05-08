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

@SuppressLint("SetJavaScriptEnabled", "JavascriptInterface")
class NimbusBridge(private val appUrl: String) {

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
        webView.loadUrl(appUrl)
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