//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.salesforce.nimbus.NimbusExtension
import com.salesforce.nimbus.addConnection
import java.util.*

class SimpleBridgeExtension : NimbusExtension {
    class Bridge {
        @JavascriptInterface
        fun currentTime(): String {
            return Date().toString()
        }
    }

    override fun bindToWebView(webView: WebView) {
        webView.addConnection(Bridge(), "DemoBridge")
    }
}