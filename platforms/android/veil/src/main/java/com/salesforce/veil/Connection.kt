// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veil

import android.annotation.SuppressLint
import android.webkit.WebView
import android.webkit.WebViewClient
import java.util.*

/**
 * Connects the specified [target] object to the [webView].
 *
 * The [target] object should have methods that are to be exposed
 * to JavaScript annotated with the [android.webkit.JavascriptInterface] annotation
 */
@SuppressLint("JavascriptInterface")
class Connection(val webView: WebView, val target: Any, val name: String) {

    init {
        webView.addJavascriptInterface(target, "_" + name)
        connectionMap[webView]?.addConnection(this)
    }

    companion object {
        val connectionMap: WeakHashMap<WebView, VeilBridge> = WeakHashMap()
    }
}

/**
 * Connect the specified [target] object to this WebView.
 *
 * The [target] object should have methods that are to be exposed
 * to JavaScript annotated with the [android.webkit.JavascriptInterface] annotation
 */
fun WebView.addConnection(target: Any, name: String) {

    if (Connection.connectionMap[this] == null) {

        Connection.connectionMap[this] = VeilBridge(this)

        this.webViewClient = object: WebViewClient() {

            override fun onPageCommitVisible(view: WebView, url: String?) {

                val veilScript = ResourceUtils(view.context).stringFromRawResource(R.raw.veil)
                view.evaluateJavascript(veilScript) {}

                Connection.connectionMap[view]?.connections?.forEach { connection ->
                    view.evaluateJavascript("""
                    ${connection.name} = Veil.promisify(_${connection.name});
                    """.trimIndent()) {}
                }

                super.onPageCommitVisible(view, url)
            }
        }
    }

    Connection(this, target, name)
}