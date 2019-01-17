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

    val html = """
        <html>
            <head>
                <meta name='viewport' content='initial-scale=1.0, user-scalable=no' />
                <script>
                    var veilTestNamespace = veilTestNamespace || {};
                    veilTestNamespace.TestObject = function(name) {
                        this.testObjectName = name;
                    }
                    veilTestNamespace.TestObject.prototype.getName = function() {
                        return this.testObjectName;
                    }
                    var testObject = new veilTestNamespace.TestObject('veil');

                    function methodWithNoParam() {
                        return "methodWithNoParam called.";
                    }

                    function methodWithMultipleParams(boolParam, intParam, optionalIntParam, stringParam, userDefinedTypeParam) {
                        const boolParamFormatted = boolParam.toString();
                        const intParamFormatted = intParam.toString();
                        var optionalIntParamFormatted = "null";
                        if (optionalIntParam != null) {
                            optionalIntParamFormatted = optionalIntParam.toString();
                        }
                        const userDefinedTypeParamFormatted = userDefinedTypeParam.toString();
                        return boolParamFormatted + ', ' + intParamFormatted + ', ' + optionalIntParamFormatted + ', ' + stringParam + ', ' + userDefinedTypeParamFormatted;
                    }

                    function methodExpectingNewline(newline) {
                        return "received newline character: " + newline;
                    }
                </script>
            </head>
            <body>
            </body>
        </html>
    """.trimIndent()

    @Before
    fun setup() {
        webView = activityRule.activity.webView

        val latch = CountDownLatch(1)
        runOnUiThread {
            webView?.let {
                it.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
                it.webViewClient = object : WebViewClient() {
                    override fun onPageFinished(view: WebView, url: String) {
                        latch.countDown()
                    }
                }

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
