// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veildemoapp

import android.support.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import android.support.test.rule.ActivityTestRule
import android.support.test.runner.AndroidJUnit4
import android.webkit.JavascriptInterface
import com.salesforce.veil.addConnection
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
public class ConnectionTests {

    class TestBridge {
        var called = false

        @JavascriptInterface
        fun test() {
            called = true
        }
    }

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule<WebViewActivity>(WebViewActivity::class.java, false, true)

    @Test
    fun connectedFunctionIsCalled() {

        val webView = activityRule.activity.webView
        val latch = CountDownLatch(1)
        val bridge = TestBridge()

        runOnUiThread {
            webView.addConnection(bridge, "TestBridge")
        }
        latch.await(5, TimeUnit.SECONDS)

        runOnUiThread {
            webView.evaluateJavascript("TestBridge.test();") { r: String ->
                latch.countDown()
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, bridge.called)
    }
}
