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
fun WebView.addConnection(target: Any, name: String) {

    if (Connection.connectionMap[this] == null) {

        Connection.connectionMap[this] = VeilBridge(this)

        this.webViewClient = object : WebViewClient() {

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

/**
 * Call a Javascript function.
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
fun WebView.callJavascript(name: String, args: List<Any>?, completionHandler: ((result: Any?, error: Exception?) -> Unit)? = null) {
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

    try {
        this.evaluateJavascript(scriptTemplate, { value ->
            completionHandler?.let {
                completionHandler(value, null)
            }
        })
    } catch (e: Exception) {
        completionHandler?.let {
            completionHandler(null, e)
        }
    }
}
