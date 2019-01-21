// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veildemoapp

import android.support.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import android.support.test.rule.ActivityTestRule
import android.support.test.runner.AndroidJUnit4
import android.webkit.WebView
import android.webkit.WebViewClient
import com.salesforce.veil.ResourceUtils
import com.salesforce.veil.callJavascript
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class CallJavascriptTests {

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
                val veilPreScript = ResourceUtils(it.context).stringFromRawResource(R.raw.evaljstests)
                it.webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView, url: String) {
                        latch.countDown()
                    }
                }
                it.loadDataWithBaseURL(null, veilPreScript, "text/html", "UTF-8", null)
            }
        }
        latch.await(5, TimeUnit.SECONDS)
    }

    @Test
    fun callMethodWithNoParam() {
        val latch = CountDownLatch(1)
        var retValMatches = false
        runOnUiThread {
            webView?.let {
                it.callJavascript("methodWithNoParam", emptyList()) { result ->
                    result?.let {
                        if (result.equals("\"methodWithNoParam called.\"")) {
                            retValMatches = true
                            latch.countDown()
                        }
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, retValMatches)
    }

    @Test
    fun callNonExistingMethod() {
        val latch = CountDownLatch(1)
        var retValMatches = false
        runOnUiThread {
            webView?.let {
                it.callJavascript("callMethodThatDoesntExist", emptyList()) { result ->
                    if (result == "null") {
                        retValMatches = true
                        latch.countDown()
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, retValMatches)
    }

    @Test
    fun callMethodWithMultipleParams() {
        val latch = CountDownLatch(1)
        var retValMatches = false
        runOnUiThread {
            val boolParam = true
            val intParam = 999
            val stringParam = "hello kotlin"
            val optionalParam: Int? = null
            val userDefinedType = MainActivity.UserDefinedType()
            webView?.let {
                it.callJavascript("methodWithMultipleParams", listOf<Any?>(boolParam, intParam, optionalParam, stringParam, userDefinedType)) { result ->
                    result?.let {
                        if (it.equals("\"true, 999, null, hello kotlin, [object Object]\"")) {
                            retValMatches = true
                            latch.countDown()
                        }
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, retValMatches)
    }

    @Test
    fun callMethodOnAnObject() {
        val latch = CountDownLatch(1)
        var retValMatches = false
        runOnUiThread {
            webView?.let {
                it.callJavascript("testObject.getName", emptyList()) { result ->
                    result?.let {
                        if (it.equals("\"veil\"")) {
                            retValMatches = true
                            latch.countDown()
                        }
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, retValMatches)
    }

    @Test
    fun callMethodExpectingNewLine() {
        val latch = CountDownLatch(1)
        var retValMatches = false
        runOnUiThread {
            webView?.let {
                it.callJavascript("methodExpectingNewline", listOf<Any?>("hello \\\\n")) { result ->
                    result?.let {
                        if (it.equals("\"received newline character: hello \\\\n\"")) {
                            retValMatches = true
                            latch.countDown()
                        }
                    }
                }
            }
        }
        latch.await(5, TimeUnit.SECONDS)

        assertEquals(true, retValMatches)
    }
}
