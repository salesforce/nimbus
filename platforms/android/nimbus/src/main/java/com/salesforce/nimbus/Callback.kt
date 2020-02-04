//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView
import org.json.JSONArray

/**
 * A [Callback] represents a javascript function that can be accepted
 * as an argument to a native method.
 */
class Callback(val webView: WebView, val callbackId: String) {

    protected fun finalize() {
        webView.post {
            webView.evaluateJavascript("window.__nimbus.releaseCallback('$callbackId');") {}
        }
    }

    /**
     * Execute the wrapped javascript function passing [args] as the arguments.
     */
    fun call(vararg args: Any) {
        val jsonArgs = JSONArray(args)
        webView.post {
            webView.evaluateJavascript("window.__nimbus.callCallback('$callbackId', $jsonArgs);") {}
        }
    }
}
