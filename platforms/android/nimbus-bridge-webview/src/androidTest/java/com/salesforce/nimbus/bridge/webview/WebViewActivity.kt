//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.webview

import android.app.Activity
import android.os.Bundle
import android.webkit.WebView
import com.salesforce.nimbus.bridge.webview.test.R

class WebViewActivity : Activity() {

    lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web_view)

        webView = findViewById(R.id.webView)
        webView.settings.javaScriptEnabled = true
    }
}
