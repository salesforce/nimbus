//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.salesforce.nimbus.NimbusBridge
import com.salesforce.nimbus.extensions.DeviceExtension
import com.salesforce.nimbus.extensions.DeviceExtensionBinder

class MainActivity : AppCompatActivity() {

    private val bridge: NimbusBridge = NimbusBridge()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true)
        val webView = findViewById<WebView>(R.id.webview)
        val deviceExtension = DeviceExtensionBinder(DeviceExtension(this))
        bridge.add(deviceExtension)
        bridge.attach(webView)
        bridge.loadUrl("http://10.0.2.2:3000")
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge.detach()
    }
}
