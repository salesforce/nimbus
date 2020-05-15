//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.webview

import android.webkit.WebView
import com.salesforce.nimbus.JSEncodable

/**
 * Asynchronously broadcast a message to subscribers listening on Javascript side.  Message can be
 * delivered with an argument so that subscriber can use that pass useful data. This method must be called on UI thread.
 *
 * @param name Message name.  Listeners are keying on unique message names on Javascript side.
 *                            There can be multiple listeners listening on same message.
 * @param arg An optional primitive type or object to pass to message listeners.
 * @param completionHandler A block to invoke when script evaluation completes or fails. You do not
 *                          have to pass a closure if you are not interested in getting the callback.
 */
fun WebView.broadcastMessage(name: String, arg: JSEncodable<String>? = null, completionHandler: ((result: Int) -> Unit)? = null) {
    val scriptTemplate: String = if (arg != null) {
        """
            try {
                var value = ${arg.encode()};
                __nimbus.broadcastMessage('$name', value);
            } catch(e) {
                console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
            }
        """.trimIndent()
    } else {
        "__nimbus.broadcastMessage('$name');"
    }
    evaluateJavascript(scriptTemplate) { value ->
        completionHandler?.let {
            completionHandler(value.toInt())
        }
    }
}

/**
 * Creates a [WebViewBridge.Builder] and passes it to the [builder] function, allowing any binders to be added
 * and then attaches to the [WebView] instance.
 */
fun WebView.bridge(builder: WebViewBridge.Builder.() -> Unit): WebViewBridge {
    return WebViewBridge.Builder().apply(builder).attach(this)
}
