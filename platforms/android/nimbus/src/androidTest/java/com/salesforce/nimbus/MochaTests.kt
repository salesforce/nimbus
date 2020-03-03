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
import android.webkit.WebView
import junit.framework.Assert.assertEquals
import junit.framework.Assert.assertTrue
import junit.framework.Assert.assertNull
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

    @Extension(name = "mochaTestBridge")
    class MochaTestBridge(val webView: WebView) : NimbusExtension {

        val readyLatch = CountDownLatch(1)
        val completionLatch = CountDownLatch(1)

        // Set to -1 initially to indicate we never got a completion callback
        var failures = -1

        @ExtensionMethod
        fun ready() {
            readyLatch.countDown()
        }

        @ExtensionMethod
        fun testsCompleted(failures: Int) {
            this.failures = failures
            completionLatch.countDown()
        }
        @ExtensionMethod
        fun onTestFail(testTitle: String, errMessage: String) {
            Log.e("MOCHA", "[$testTitle]: $errMessage")
        }

        @ExtensionMethod
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
            bridge.add(CallbackTestExtensionBinder(CallbackTestExtension()))
            bridge.add(MochaTestBridgeBinder(testBridge))
            bridge.attach(webView)
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        assertTrue(testBridge.readyLatch.await(5, TimeUnit.SECONDS))

        runOnUiThread {
            webView.evaluateJavascript("""
            const titleFor = x => x.parent ? (titleFor(x.parent) + " " + x.title) : x.title
            mocha.run(failures => { __nimbus.plugins.mochaTestBridge.testsCompleted(failures); })
                 .on('fail', (test, err) => __nimbus.plugins.mochaTestBridge.onTestFail(titleFor(test), err.message));
            true;
            """.trimIndent()) {}
        }

        assertTrue(testBridge.completionLatch.await(5, TimeUnit.SECONDS))

        assertEquals(0, testBridge.failures)
    }

    @Test
    fun testExecutePromiseResolved() {
        val webView = activityRule.activity.webView
        val testBridge = MochaTestBridge(webView)

        val bridge = NimbusBridge()
        val callbackTestBinder = CallbackTestExtensionBinder(CallbackTestExtension())

        runOnUiThread {
            bridge.add(callbackTestBinder)
            bridge.add(MochaTestBridgeBinder(testBridge))
            bridge.attach(webView)
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        assertTrue(testBridge.readyLatch.await(5, TimeUnit.SECONDS))
        val completionLatch = CountDownLatch(1)
        runOnUiThread {
            callbackTestBinder.addOne(5) { err, result ->
                assertNull(err)
                assertEquals(6, result)
                completionLatch.countDown()
            }
        }

        assertTrue(completionLatch.await(5, TimeUnit.SECONDS))
    }

    @Test
    fun testExecutePromiseRejected() {
        val webView = activityRule.activity.webView
        val testBridge = MochaTestBridge(webView)

        val bridge = NimbusBridge()
        val callbackTestBinder = CallbackTestExtensionBinder(CallbackTestExtension())

        runOnUiThread {
            bridge.add(MochaTestBridgeBinder(testBridge))
            bridge.add(callbackTestBinder)
            bridge.attach(webView)
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        assertTrue(testBridge.readyLatch.await(5, TimeUnit.SECONDS))
        val completionLatch = CountDownLatch(1)
        runOnUiThread {
            callbackTestBinder.failWith("epic fail") { err, result ->
                assertEquals("epic fail", err)
                assertNull(result)
                completionLatch.countDown()
            }
        }

        assertTrue(completionLatch.await(5, TimeUnit.SECONDS))
    }

    @Test
    fun testPromiseRejectedOnRefresh() {
        val webView = activityRule.activity.webView
        val testBridge = MochaTestBridge(webView)

        val bridge = NimbusBridge()
        val callbackTestBinder = CallbackTestExtensionBinder(CallbackTestExtension())

        runOnUiThread {
            bridge.add(MochaTestBridgeBinder(testBridge))
            bridge.add(callbackTestBinder)
            bridge.attach(webView)
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        assertTrue(testBridge.readyLatch.await(5, TimeUnit.SECONDS))
        val completionLatch = CountDownLatch(1)
        runOnUiThread {
            callbackTestBinder.wait(60000) { err, _ ->
                assertEquals("ERROR_PAGE_UNLOADED", err)
                completionLatch.countDown()
            }
        }

        runOnUiThread {
            // Destroy the existing web page & JS context
            bridge.loadUrl("file:///android_asset/test-www/index.html")
        }

        assertTrue(completionLatch.await(5, TimeUnit.SECONDS))
    }
}
