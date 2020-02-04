//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView
import org.json.JSONArray
import org.json.JSONObject

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
    val jsonArray = JSONArray()
    args.forEachIndexed { index, jsonSerializable ->
        val asPrimitive = jsonSerializable as? PrimitiveJSONSerializable
        if (asPrimitive != null) {
            jsonArray.put(asPrimitive.value)
        } else {
            jsonArray.put(if (jsonSerializable == null) JSONObject.NULL
                    else JSONObject(jsonSerializable.stringify()))
        }
    }

    val jsonString = jsonArray.toString()
    val scriptTemplate = """
        try {
            var jsonArr = $jsonString;
            if (jsonArr && jsonArr.length > 0) {
                $name(...jsonArr);
            } else {
                $name();
            }
        } catch(e) {
            console.log('Error parsing JSON during a call to callJavascript:' + e.toString());
        }
    """.trimIndent()

    handler.post {
        evaluateJavascript(scriptTemplate) { value ->
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
    val scriptTemplate: String = if (arg != null) {
        """
            try {
                var value = ${arg.stringify()};
                window.__nimbus.broadcastMessage('$name', value);
            } catch(e) {
                console.log('Error parsing JSON during a call to broadcastMessage:' + e.toString());
            }
        """.trimIndent()
    } else {
        "window.__nimbus.broadcastMessage('$name');"
    }
    evaluateJavascript(scriptTemplate) { value ->
        completionHandler?.let {
            completionHandler(value.toInt())
        }
    }
}
