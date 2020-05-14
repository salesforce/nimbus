//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.eclipsesource.v8.V8
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import com.salesforce.nimbus.bridge.v8.V8Bridge
import com.salesforce.nimbus.bridge.webview.WebViewBridge
import com.salesforce.nimbus.core.plugins.DeviceInfoPlugin
import com.salesforce.nimbus.core.plugins.DeviceInfoPluginV8Binder
import com.salesforce.nimbus.core.plugins.DeviceInfoPluginWebViewBinder

class MainActivity : AppCompatActivity() {

    private lateinit var webViewBridge: WebViewBridge
    private lateinit var v8Bridge: V8Bridge
    private lateinit var v8: V8

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true)
        val webView = findViewById<WebView>(R.id.webview)

        // create the device info plugin
        val deviceInfoPlugin = DeviceInfoPlugin(this)

        // create the web view bridge
        webViewBridge = WebViewBridge().apply {
            add(DeviceInfoPluginWebViewBinder(deviceInfoPlugin))
            attach(webView)
        }

        // load the demo url
        webView.loadUrl("http://10.0.2.2:3000")

        // create a v8 runtime
        v8 = V8.createV8Runtime()

        // create the v8 bridge
        v8Bridge = V8Bridge().apply {
            add(DeviceInfoPluginV8Binder(deviceInfoPlugin))
            add(LogPluginV8Binder(LogPlugin()))
            add(ToastPluginV8Binder(ToastPlugin(this@MainActivity.applicationContext)))
            attach(v8)
        }

        // execute a script to get the device info plugin and then log to the console
        v8.executeScript(
            """
            __nimbus.plugins.DeviceInfoPlugin.getDeviceInfo().then((deviceInfo) => {
                let json = JSON.stringify(deviceInfo);
                __nimbus.plugins.LogPlugin.debug('DemoApp', json);
                __nimbus.plugins.ToastPlugin.toast('Device Info from V8: ' + json);
            });
            """.trimIndent()
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        webViewBridge.detach()
        v8Bridge.detach()
        v8.close()
    }
}

@PluginOptions("LogPlugin")
class LogPlugin : Plugin {

    @BoundMethod
    fun debug(tag: String, message: String) {
        Log.d(tag, message)
    }
}

@PluginOptions("ToastPlugin")
class ToastPlugin(private val context: Context) : Plugin {

    @BoundMethod
    fun toast(message: String) {
        Toast.makeText(context, message, Toast.LENGTH_LONG).show()
    }
}
