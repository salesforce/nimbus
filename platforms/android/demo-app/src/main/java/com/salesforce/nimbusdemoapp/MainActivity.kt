//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.os.Bundle
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity
import com.salesforce.nimbus.bridge.webview.WebViewBridge
import com.salesforce.nimbus.bridge.webview.plugins.DeviceInfoPlugin
import com.salesforce.nimbus.bridge.webview.plugins.DeviceInfoPluginWebViewBinder

class MainActivity : AppCompatActivity() {

    private val bridge = WebViewBridge()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true)
        val webView = findViewById<WebView>(R.id.webview)
        val deviceInfoPlugin = DeviceInfoPluginWebViewBinder(DeviceInfoPlugin(this))
        bridge.add(deviceInfoPlugin)
        bridge.attach(webView)
        webView.loadUrl("http://10.0.2.2:3000")
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge.detach()
    }
}
