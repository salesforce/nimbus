//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.salesforce.nimbus.*
import java.util.*

@Extension
class SimpleBridgeExtension : NimbusExtension {
//    class Bridge {
//
//    }

    data class Foo(val name: String, val title: String)

    @ExtensionMethod
    @JavascriptInterface
    fun currentTime(): String {
        return Date().toString()
    }

    @ExtensionMethod
    fun anotherMethod(arg: String, arg2: Int, arg3: Foo): String {
        return ""
    }

    @ExtensionMethod
    fun voidReturn(arg: Int) {

    }

    @ExtensionMethod
    fun funArg(arg: (String, Int) -> Void) {
        arg("result", 37)
    }

    @JavascriptInterface
    fun funArg1(arg: Callback) {
        arg.call(arrayOf("result"))

    }

    override fun bindToWebView(webView: WebView) {
        webView.addConnection(this, "DemoBridge")
    }
}