//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.annotation.SuppressLint
import android.webkit.WebView
import android.webkit.WebViewClient
import org.json.JSONObject
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
        val clazz = target::class
        val className = clazz.java.name
        val binderName = className + "Binder"
        val binderClass = clazz.java.classLoader.loadClass(binderName)
        val constructor = binderClass.getConstructor(clazz.java, WebView::class.java)

        val binder = constructor.newInstance(target, webView);

        // TODO: ?
        webView.addJavascriptInterface(binder, "_" + name)

        connectionMap[webView]?.addConnection(this)
    }

    companion object {
        val connectionMap: WeakHashMap<WebView, NimbusConnectionBridge> = WeakHashMap()
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
        Connection.connectionMap[this] = NimbusConnectionBridge(this)
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
fun WebView.callJavascript(name: String, args: Array<JSONSerializable?> = emptyArray(), completionHandler: ((result: Any?) -> Unit)? = null) {
    val jsonObject = JSONObject()
    args.forEachIndexed { index, jsonSerializable ->
        val asPrimitive = jsonSerializable as? PrimitiveJSONSerializable;
        if (asPrimitive != null) {
            jsonObject.put(index.toString(), asPrimitive.value)
        } else {
            jsonObject.put(index.toString(),
                    if (jsonSerializable == null) JSONObject.NULL
                    else JSONObject(jsonSerializable.stringify()))
        }
    }

    val jsonString = jsonObject.toString()
    val scriptTemplate = """
        try {
            var jsonData = ${jsonString};
            var jsonArr = Object.values(jsonData);
            if (jsonArr && jsonArr.length > 0) {
                ${name}(...jsonArr);
            } else {
                ${name}();
            }
        } catch(e) {
            console.log('Error parsing JSON during a call to callJavascript:' + e.toString());
        }
    """.trimIndent()

    this.handler.post {
        this.evaluateJavascript(scriptTemplate) { value ->
            completionHandler?.let {
                completionHandler(value)
            }
        }
    }
}

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
fun WebView.broadcastMessage(name: String, arg: JSONSerializable? = null, completionHandler: ((result: Int) -> Unit)? = null) {
    var scriptTemplate: String
    if (arg != null) {
        scriptTemplate = """
            try {
                var value = ${arg.stringify()};
                nimbus.broadcastMessage('${name}', value);
            } catch(e) {
                console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
            }
        """.trimIndent()

    } else {
        scriptTemplate = "nimbus.broadcastMessage('${name}');"
    }
    this.evaluateJavascript(scriptTemplate) { value ->
        completionHandler?.let {
            completionHandler(value.toInt())
        }
    }
}
