// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veil

import android.annotation.SuppressLint
import android.webkit.WebView
import android.webkit.WebViewClient
import com.google.gson.Gson
import java.util.*

/**
 * Connects the specified [target] object to the [webView].
 *
 * The [target] object should have methods that are to be exposed
 * to JavaScript annotated with the [android.webkit.JavascriptInterface] annotation
 */
@SuppressLint("JavascriptInterface")
internal class Connection(val webView: WebView, val target: Any, val name: String) {

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
fun WebView.addConnection(target: Any, name: String, preScript: String? = null) {

    if (Connection.connectionMap[this] == null) {

        Connection.connectionMap[this] = VeilBridge(this)

        this.webViewClient = object : WebViewClient() {

            override fun onPageCommitVisible(view: WebView, url: String?) {
                val veilScript = ResourceUtils(view.context).stringFromRawResource(R.raw.veil)
                view.evaluateJavascript(veilScript) {
                    // Run pre-script that needs Veil immediately after Veil is loaded
                    preScript?.let {
                        view.evaluateJavascript(it) {
                            Connection.connectionMap[view]?.connections?.forEach { connection ->
                                view.evaluateJavascript("""
                                                        ${connection.name} = Veil.promisify(_${connection.name});
                                                        """.trimIndent()) {}
                            }
                        }
                    } ?: run {
                        Connection.connectionMap[view]?.connections?.forEach { connection ->
                            view.evaluateJavascript("""
                    ${connection.name} = Veil.promisify(_${connection.name});
                    """.trimIndent()) {}
                        }
                    }
                }
            }
        }
    }

    Connection(this, target, name)
}

/**
 * Asynchronously call a Javascript function. This method must be called on UI thread.
 *
 * @param name Name of a function or a method on an object to call.  Fully qualify this name
 *             by separating with a dot and do not need to add parenthesis. The function
 *             to be performed in Javascript must already be defined and exist there.  Do not
 *             pass a snippet of code to evaluate.
 * @param args Array of argument objects.  They will be Javascript stringified in this
 *             method and be passed the function as specified in 'name'. If you are calling a
 *             Javascript function that does not take any parameters pass empty array instead of nil.
 * @param completionHandler A block to invoke when script evaluation completes or fails. You do not
 *                          have to pass a closure if you are not interested in getting the callback.
 */
fun WebView.callJavascript(name: String, args: List<Any?> = emptyList(), completionHandler: ((result: Any?) -> Unit)? = null) {
    val gson = Gson()
    val jsonString = gson.toJson(args)
    val scriptTemplate = """
        try {
            var jsonArr = JSON.parse('${jsonString}');
            if (jsonArr && jsonArr.length > 0) {
                ${name}(...jsonArr);
            } else {
                ${name}();
            }
        } catch(e) {
            console.log('Error parsing JSON during a call to callJavascript:' + e.toString());
        }
    """.trimIndent()

    this.evaluateJavascript(scriptTemplate) { value ->
        completionHandler?.let {
            completionHandler(value)
        }
    }
}

/**
 * Asynchronously broadcast a message to subscribers listening on Javascript side.  Message can be
 * delivered with an argument so that subscriber can use that pass useful data. This method must be called on UI thread.
 *
 * @param name Message name.  Listeners are keying on unique message names on Javascript side.
 *                            There can be multiple listeners listening on same message.
 * @param arg Any primitive type or ojbect to pass to Javascript as useful data.  If there is nothing to be
 *            passed don't specify the parameter since it has nil as default parameter.
 * @param completionHandler A block to invoke when script evaluation completes or fails. You do not
 *                          have to pass a closure if you are not interested in getting the callback.
 */
fun WebView.broadcastMessage(name: String, arg: Any? = null, completionHandler: ((result: Int) -> Unit)? = null) {
    var scriptTemplate: String
    if (arg != null) {
        val gson = Gson()
        val jsonString = gson.toJson(arg)
        scriptTemplate = """
            try {
                var jsonData = JSON.parse('${jsonString}');
                if (jsonData) {
                    Veil.broadcastMessage('${name}',jsonData);
                } else {
                    Veil.broadcastMessage('${name}');
                }
            } catch(e) {
                console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
            }
        """.trimIndent()

    } else {
        scriptTemplate = "Veil.broadcastMessage('${name}');"
    }
    this.evaluateJavascript(scriptTemplate) { value ->
        completionHandler?.let {
            completionHandler(value.toInt())
        }
    }
}
