// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veil

import android.webkit.JavascriptInterface
import android.webkit.WebView
import java.lang.ref.WeakReference

/**
 * The VeilBridge contains some helper methods for integration
 * of native and javascript.
 */
class VeilBridge(webView: WebView) {

    private val webView: WeakReference<WebView> = WeakReference(webView)

    val connections: MutableCollection<Connection> = ArrayList()

    init {
        webView.addJavascriptInterface(this, "_Veil")
    }

    fun addConnection(connection: Connection) {
        connections.add(connection)
    }

    @JavascriptInterface
    fun makeCallback(callbackId: String): Callback? {
        webView.get()?.let {
            return Callback(it, callbackId)
        }
        return null
    }

}