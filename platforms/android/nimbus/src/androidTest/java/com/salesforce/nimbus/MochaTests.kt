//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.util.Log
import androidx.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import androidx.test.rule.ActivityTestRule
import androidx.test.runner.AndroidJUnit4
import android.webkit.JavascriptInterface
import android.webkit.WebView
import junit.framework.Assert.assertEquals
import org.json.JSONObject
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class MochaTests {

    data class MochaMessage(val stringField: String = "This is a string", val intField: Int = 42) : JSONSerializable {
        override fun stringify(): String {
            val jsonObject = JSONObject()
            jsonObject.put("stringField", stringField)
            jsonObject.put("intField", intField)
            return jsonObject.toString()
        }
    }

    class MochaTestBridge(val webView: WebView) {

        val readyLatch = CountDownLatch(1)
        val completionLatch = CountDownLatch(1)

        // Set to -1 initially to indicate we never got a completion callback
        var failures = -1

        @JavascriptInterface
        fun ready() {
            readyLatch.countDown()
        }

        @JavascriptInterface
        fun testsCompleted(failures: Int) {
            this.failures = failures
            completionLatch.countDown()
        }
        @JavascriptInterface
        fun onTestFail(testTitle: String, errMessage: String) {
            failures += 1;
            Log.e("MOCHA", "[$testTitle]: $errMessage")
        }

        @JavascriptInterface
        fun sendMessage(name: String, includeParam: Boolean) {
            webView.post {
                var arg: JSONSerializable? = null
                if (includeParam) {
                    arg = MochaMessage()
                }
                webView.broadcastMessage(name, arg)
            }
        }
    }

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule<WebViewActivity>(WebViewActivity::class.java, false, true)

    @Test
    fun runMochaTests() {

        val webView = activityRule.activity.webView
        val testBridge = MochaTestBridge(webView)

        val bridge = NimbusBridge()

        runOnUiThread {
            webView.addJavascriptInterface(testBridge, "mochaTestBridge")
            bridge.add(CallbackTestExtensionBinder(CallbackTestExtension()))
            bridge.attach(webView)
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        testBridge.readyLatch.await(5, TimeUnit.SECONDS)

        runOnUiThread {
            webView.evaluateJavascript("mocha.run(failures => { mochaTestBridge.testsCompleted(failures); }).on('fail', (test, err) => mochaTestBridge.onTestFail(test.title, err.message)); true;") {}
        }

        testBridge.completionLatch.await(5, TimeUnit.SECONDS)

        assertEquals(0, testBridge.failures)
    }
}
