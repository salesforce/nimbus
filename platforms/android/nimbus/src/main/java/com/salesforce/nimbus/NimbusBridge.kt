//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.annotation.SuppressLint
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import org.json.JSONArray
import kotlin.reflect.KClass

@SuppressLint("SetJavaScriptEnabled", "JavascriptInterface")
class NimbusBridge(private val appUrl: String) {

    companion object {
        private const val BRIDGE_NAME = "_nimbus"
    }

    private var bridgeWebView: WebView? = null
    private val extensions: MutableList<NimbusExtension> = arrayListOf()
    private val binders: MutableMap<NimbusExtension, NimbusBinder> = mutableMapOf()

    /**
     * Adds a [NimbusExtension] to the bridge. NOTE: The [NimbusExtension] must be annotated with
     * [Extension].
     */
    fun addExtension(extension: NimbusExtension) {
        if (isAnnotatedWith(extension, Extension::class)) {
            extensions.add(extension)
        } else {
            Log.e(NimbusBridge::class.java.simpleName,
                "NimbusExtension ${extension::class.simpleName} must be annotated with Extension annotation.")
        }
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
        initializeExtensions(webView, extensions)
        webView.loadUrl(appUrl)
    }

    /**
     * Detaches the bridge performing any necessary cleanup.
     */
    fun detach() {
        bridgeWebView?.let { webView ->
            webView.removeJavascriptInterface(BRIDGE_NAME)
            cleanupExtensions(webView, extensions)
        }
        extensions.clear()
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
        val names = binders.values.map { it.getExtensionName() }
        val result = JSONArray(names)
        return result.toString()
    }

    private fun initializeExtensions(webView: WebView, extensions: Collection<NimbusExtension>) {
        extensions

            // customize web view if needed
            .onEach { extension -> extension.customize(webView) }

            // get binder for extension and map to binders
            .associateWithTo(binders) { extension -> getBinder(webView, extension)}

            // add the javascript interface for the binder
            .forEach { (_, binder) ->
                val extensionName = binder.getExtensionName()
                webView.addJavascriptInterface(binder, "_$extensionName")
            }
    }

    private fun cleanupExtensions(webView: WebView, extensions: Collection<NimbusExtension>) {
        extensions

            // cleanup web view if needed
            .onEach { extension -> extension.cleanup(webView) }

            // map to extension name
            .mapNotNull { extension -> binders[extension]?.getExtensionName() }

            // remove the javascript interface for the binder
            .forEach { extensionName -> webView.removeJavascriptInterface("_$extensionName") }
    }

    private inline fun <reified T : Any> isAnnotatedWith(t: T, annotationClass: KClass<*>) =
        isAnnotated(t::class, annotationClass)

    private fun isAnnotated(inputClass: KClass<*>, annotationClass: KClass<*>) =
        inputClass.annotations.any { it.annotationClass == annotationClass }

    private fun getBinder(webView: WebView, extension: NimbusExtension): NimbusBinder {
        val clazz = extension::class
        val className = clazz.java.name
        val binderName = className + "Binder"
        val binderClass = clazz.java.classLoader?.loadClass(binderName)
        val constructor = binderClass?.getConstructor(clazz.java, WebView::class.java)
        return constructor?.let {
            it.newInstance(extension, webView) as NimbusBinder
        } ?: throw RuntimeException("Binder class for $className was not found. " +
                "Make sure you have annotation processing enabled in your project.")
    }
}