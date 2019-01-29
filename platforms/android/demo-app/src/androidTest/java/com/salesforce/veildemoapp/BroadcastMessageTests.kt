// Copyright (c) 2019, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veildemoapp

import android.support.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import android.support.test.rule.ActivityTestRule
import android.support.test.runner.AndroidJUnit4
import android.util.Log
import android.webkit.WebView
import android.webkit.WebViewClient
import com.salesforce.veil.Connection
import com.salesforce.veil.ResourceUtils
import com.salesforce.veil.addConnection
import com.salesforce.veil.broadcastMessage
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class BroadcastMessageTests {
    init {
        WebView.setWebContentsDebuggingEnabled(true);
    }

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule<WebViewActivity>(WebViewActivity::class.java, false, true)

    var webView: WebView? = null

    @Before
    fun setup() {
        webView = activityRule.activity.webView
        val latch = CountDownLatch(1)
        runOnUiThread {
            webView?.let {
                val bridge = ConnectionTests.TestBridge()
                val veilPreScript = ResourceUtils(it.context).stringFromRawResource(R.raw.broadcasttests)
                it.addConnection(bridge, "TestBridge", veilPreScript)
            }
        }
        latch.await(5, TimeUnit.SECONDS)
        runOnUiThread {
            webView?.let {
                it.loadDataWithBaseURL(null, "<html><body></body></html>", "text/html", "UTF-8", null)
            }

        }
        latch.await(5, TimeUnit.SECONDS)
    }

    @Test
    fun broadcastMessageWithNoParam() {
        var callCountMatches = false
        val latch = CountDownLatch(1)
        webView?.let {
            runOnUiThread {
                it.broadcastMessage("testMessageWithNoParam") {
                    if (1 == it) {
                        callCountMatches = true
                        latch.countDown()
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)
        assertEquals(true, callCountMatches)
    }

    @Test
    fun broadcastMessageWithParam() {
        var callCountMatches = false
        val latch = CountDownLatch(1)
        webView?.let {
            runOnUiThread {
                val testArg = MainActivity.UserDefinedType()
                it.broadcastMessage("testMessageWithParam", testArg) {
                    if (1 == it) {
                        callCountMatches = true
                        latch.countDown()
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)
        assertEquals(true, callCountMatches)
    }

    @Test
    fun broadcastMessageWithNoHandler() {
        // Test unsubscribing of a message handler
        var callCountMatches = false
        var latch = CountDownLatch(1)
        webView?.let {
            runOnUiThread {
                it.broadcastMessage("testUnsubscribingHandler") {
                    if (1 == it) {
                        callCountMatches = true
                        latch.countDown()
                    }
                }
            }

        }
        latch.await(5, TimeUnit.SECONDS)
        assertEquals(true, callCountMatches)

        // Test that no message handler is called
        callCountMatches = false
        latch = CountDownLatch(1)
        webView?.let {
            runOnUiThread {
                it.broadcastMessage("testMessageWithNoParam") {
                    if (0 == it) {
                        callCountMatches = true
                        latch.countDown()
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)
        assertEquals(true, callCountMatches)
    }
}
