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
import com.salesforce.nimbus.NimbusBridge

class MainActivity : AppCompatActivity() {

    private val bridge: NimbusBridge = NimbusBridge("http://10.0.2.2:3000")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val webView = findViewById<WebView>(R.id.webview)
        bridge.addExtension(SimpleBridgeExtension())
        bridge.attach(webView)
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge.detach()
    }
}
