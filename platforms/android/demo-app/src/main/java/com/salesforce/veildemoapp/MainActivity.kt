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
import com.salesforce.veil.Callback
import com.salesforce.veil.addConnection
import com.salesforce.veil.callJavascript
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.*


class MainActivity : AppCompatActivity() {

    class Bridge(private var webView: WebView? = null) {
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
        fun initiateNativeCallingJS() {
            GlobalScope.launch(Dispatchers.Main) {
                webView?.let {
                    val parameters = mutableListOf<Any>()
                    parameters.add(true)
                    parameters.add(999)
                    parameters.add("hello kotlin")
                    parameters.add(UserDefinedType())
                    it.callJavascript("demoMethodForNativeToJs", parameters, { result ->
                        Log.d("js", "${result}")
                    })
                }
            }
        }
    }

    class UserDefinedType() {
        val intParam = 5
        val stringParam = "hello user defined type"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true);

        val webView: WebView = findViewById(R.id.webView)
        webView.getSettings().setJavaScriptEnabled(true);

        webView.addConnection(Bridge(webView), "Bridge")

        webView.loadDataWithBaseURL(null, html, "text/html", null, null)

    }

    val html = """
        <html>
            <head>
                <meta name='viewport' content='initial-scale=1.0, user-scalable=no' />
                <script>
                function showAlert() {
                    Bridge.showAlert('hello from javascript!');
                }
                function logCurrentTime() {
                    Bridge.currentTime().then( time => { console.log(time) });
                }
                function withCallback() {
                    Bridge.withCallback((...args) => { console.log(`got back ${'$'}{args}`) });
                }
                function initiateNativeCallingJs() {
                    Bridge.initiateNativeCallingJS();
                }
                function demoMethodForNativeToJs(boolParam, intParam, stringParam, userDefinedTypeParam) {
                    const boolParamFormatted = boolParam.toString();
                    const intParamFormatted = intParam.toString();
                    const userDefinedTypeParamFormatted = userDefinedTypeParam.toString();
                    console.log(boolParamFormatted, intParamFormatted, stringParam, userDefinedTypeParamFormatted);
                    return boolParamFormatted + ', ' + intParamFormatted + ', ' + stringParam + ', ' + userDefinedTypeParamFormatted;
                }
                </script>
            </head>

            <body>
                <button onclick='showAlert();'>Show Alert</button><br>
                <button onclick='logCurrentTime();'>Log Time</button><br>
                <button onclick='withCallback();'>Callback</button><br>
                <button onclick='initiateNativeCallingJs();'>Tell native code to call js</button></br>
                <button onclick='initiateNativeBroadcastMessage();'>Tell native code to broadcast message to js</button></br>
            </body>
        </html>
    """.trimIndent()
}
