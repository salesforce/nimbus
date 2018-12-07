/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


package com.salesforce.veil

import android.webkit.WebView
import org.json.JSONArray

/**
 * A [Callback] represents a javascript function that can be accepted
 * as an argument to a native method.
 */
class Callback(val webView: WebView, val callbackId: String) {

    protected fun finalize() {
        webView.post {
            webView.evaluateJavascript("delete Veil.callbacks['${callbackId}'];") {}
        }
    }

    /**
     * Execute the wrapped javascript function passing [args] as the arguments.
     */
    fun call(vararg args: Any) {
        val jsonArgs = JSONArray(args)
        webView.post {
            webView.evaluateJavascript("Veil.callCallback('${callbackId}', ${jsonArgs});") {}
        }
    }

}