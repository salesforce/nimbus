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
        val webView = findViewById<WebView>(R.id.webview)
        val deviceExtension = DeviceExtensionBinder(DeviceExtension(this))
        bridge.add(deviceExtension)
        bridge.attach(webView)

        webView.webViewClient = object: WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                runOnUiThread {
                    deviceExtension.getWebInfo { err, result ->
                        if (err != null) {
                            println("Error: $err")
                        } else {
                            println("href: ${result.href}")
                            println("userAgent: ${result.userAgent}")
                        }
                    }
                }
            }
        }

        bridge.loadUrl("http://10.0.2.2:3000")
        WebView.setWebContentsDebuggingEnabled(true)
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge.detach()
    }
}
