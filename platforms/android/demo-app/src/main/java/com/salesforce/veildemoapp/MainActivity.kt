// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veildemoapp

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.salesforce.veil.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.util.*


class MainActivity : AppCompatActivity() {

    class DemoAppBridge(private var webView: WebView? = null) {
        @JavascriptInterface
        fun showAlert(message: String) {
            Log.d("js", message)
        }

        @JavascriptInterface
        fun currentTime(): String {
            return Date().toString()
        }

        @JavascriptInterface
        fun withCallback(callback: Callback) {
            callback.call(1, "two", "three", 4.0)
        }

        @JavascriptInterface
        fun initiateNativeCallingJs() {
            GlobalScope.launch(Dispatchers.Main) {
                webView?.let {
                    val parameters = arrayListOf<JSONSerializable?>()
                    parameters.add(true.toJSONSerializable())
                    parameters.add(999.toJSONSerializable())
                    parameters.add(null)
                    parameters.add("hello kotlin".toJSONSerializable())
                    parameters.add(UserDefinedType())
                    it.callJavascript("demoMethodForNativeToJs", parameters.toTypedArray()) { result ->
                        Log.d("js", "${result}")
                    }
                }
            }
        }

        @JavascriptInterface
        fun initiateNativeBroadcastMessage() {
            GlobalScope.launch(Dispatchers.Main) {
                webView?.broadcastMessage("systemAlert", "red".toJSONSerializable())
            }
        }
    }

    class UserDefinedType : JSONSerializable {
        val intParam = 5
        val stringParam = "hello user defined type"

        override fun stringify(): String {
            val jsonObject = JSONObject()
            jsonObject.put("intParam", intParam)
            jsonObject.put("stringParam", stringParam)
            return jsonObject.toString()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true);

        val webView: WebView = findViewById(R.id.webView)
        webView.getSettings().setJavaScriptEnabled(true);

        val veilPreScript = ResourceUtils(this.applicationContext).stringFromRawResource(R.raw.prescript)
        webView.addConnection(DemoAppBridge(webView), "DemoAppBridge", veilPreScript)
        webView.loadUrl("file:///android_asset/demoApp/index.html");
    }
}
