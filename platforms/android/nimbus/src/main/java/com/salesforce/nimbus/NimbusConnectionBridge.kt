//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.JavascriptInterface
import android.webkit.WebView
import org.json.JSONArray
import java.lang.ref.WeakReference

/**
 * The NimbusConnectionBridge contains some helper methods for integration
 * of native and javascript.
 */
class NimbusConnectionBridge(webView: WebView) {

    private val webView: WeakReference<WebView> = WeakReference(webView)

    internal val connections: MutableCollection<Connection> = ArrayList()

    init {
        webView.addJavascriptInterface(this, "_nimbus")
    }

    internal fun addConnection(connection: Connection) {
        connections.add(connection)
    }

    /**
     * Creates and returns a Callback object that can be passed as an argument to
     * a subsequent JavascriptInterface bound method.
     */
    @JavascriptInterface
    fun makeCallback(callbackId: String): Callback? {
        webView.get()?.let {
            return Callback(it, callbackId)
        }
        return null
    }

    /**
     * Return the names of all connected extensions so they can be processed by the
     * JavaScript runtime code.
     */
    @JavascriptInterface
    fun nativeExtensionNames(): String {
        var names = connections.map { it.name }
        var result = JSONArray(names)
        return result.toString()
    }

}
