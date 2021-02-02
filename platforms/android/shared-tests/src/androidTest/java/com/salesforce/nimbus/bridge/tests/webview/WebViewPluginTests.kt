//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.tests.webview

import android.webkit.WebView
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import androidx.test.rule.ActivityTestRule
import com.google.common.truth.Truth.assertThat
import com.salesforce.nimbus.bridge.tests.WebViewActivity
import com.salesforce.nimbus.bridge.tests.plugin.ExpectPlugin
import com.salesforce.nimbus.bridge.tests.plugin.StructEvent
import com.salesforce.nimbus.bridge.tests.plugin.TestPlugin
import com.salesforce.nimbus.bridge.tests.plugin.TestStruct
import com.salesforce.nimbus.bridge.tests.plugin.webViewBinder
import com.salesforce.nimbus.bridge.tests.withTimeoutInSeconds
import com.salesforce.nimbus.bridge.tests.withinLatch
import com.salesforce.nimbus.bridge.webview.WebViewBridge
import com.salesforce.nimbus.bridge.webview.bridge
import com.salesforce.nimbus.toJSONEncodable
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.Ignore
import org.junit.runner.RunWith
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class WebViewPluginTests {

    private lateinit var webView: WebView
    private lateinit var bridge: WebViewBridge
    private lateinit var expectPlugin: ExpectPlugin
    private lateinit var testPlugin: TestPlugin

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule(
        WebViewActivity::class.java, false, true
    )

    @Before
    fun setUp() {
        webView = activityRule.activity.webView
        expectPlugin = ExpectPlugin()
        testPlugin = TestPlugin()
        runOnUiThread {
            bridge = webView.bridge {
                bind { expectPlugin.webViewBinder() }
                bind { testPlugin.webViewBinder() }
            }
            webView.loadUrl("file:///android_asset/test-www/shared-tests.html")
        }
    }

    @After
    fun tearDown() {
        runOnUiThread {
            bridge.detach()
        }
    }

    // region invoke

    @Test
    fun testExecutePromiseResolved() {
        expectPlugin.testReady.withTimeoutInSeconds(30) {
            withinLatch {
                runOnUiThread {
                    bridge.invoke(
                        "__nimbus.plugins.testPlugin.addOne",
                        arrayOf(5.toJSONEncodable())
                    ) { err, result ->
                        assertThat(err).isNull()
                        assertThat(result).isEqualTo(6)
                        countDown()
                    }
                }
            }
        }
    }

    @Test
    fun testExecutePromiseRejected() {
        expectPlugin.testReady.withTimeoutInSeconds(30) {
            withinLatch {
                runOnUiThread {
                    bridge.invoke(
                        "__nimbus.plugins.testPlugin.failWith",
                        arrayOf("epic fail".toJSONEncodable())
                    ) { err, result ->
                        assertThat(err).isEqualTo("epic fail")
                        assertThat(result).isNull()
                        countDown()
                    }
                }
            }
        }
    }

    @Test
    fun testPromiseRejectedOnRefresh() {
        expectPlugin.testReady.withTimeoutInSeconds(30) {
            withinLatch {
                runOnUiThread {
                    bridge.invoke(
                        "__nimbus.plugins.testPlugin.wait",
                        arrayOf(60000.toJSONEncodable())
                    ) { err, _ ->
                        assertThat(err).isEqualTo("ERROR_PAGE_UNLOADED")
                        countDown()
                    }

                    // Destroy the existing web page & JS context
                    webView.loadUrl("file:///android_asset/test-www/index.html")
                }
            }
        }
    }

    // endregion

    // region nullary parameters

    @Test
    fun verifyNullaryResolvingToInt() {
        executeTest("verifyNullaryResolvingToInt()")
    }

    @Test
    fun verifyNullaryResolvingToDouble() {
        executeTest("verifyNullaryResolvingToDouble()")
    }

    @Test
    fun verifyNullaryResolvingToString() {
        executeTest("verifyNullaryResolvingToString()")
    }

    @Test
    fun verifyNullaryResolvingToStruct() {
        executeTest("verifyNullaryResolvingToStruct()")
    }

    @Test
    fun verifyNullaryResolvingToDateWrapper() {
        executeTest("verifyNullaryResolvingToDateWrapper()")
    }

    @Test
    fun verifyNullaryResolvingToIntList() {
        executeTest("verifyNullaryResolvingToIntList()")
    }

    @Test
    fun verifyNullaryResolvingToDoubleList() {
        executeTest("verifyNullaryResolvingToDoubleList()")
    }

    @Test
    fun verifyNullaryResolvingToStringList() {
        executeTest("verifyNullaryResolvingToStringList()")
    }

    @Test
    fun verifyNullaryResolvingToStructList() {
        executeTest("verifyNullaryResolvingToStructList()")
    }

    @Test
    fun verifyNullaryResolvingToIntArray() {
        executeTest("verifyNullaryResolvingToIntArray()")
    }

    @Test
    fun verifyNullaryResolvingToStringStringMap() {
        executeTest("verifyNullaryResolvingToStringStringMap()")
    }

    @Test
    fun verifyNullaryResolvingToStringIntMap() {
        executeTest("verifyNullaryResolvingToStringIntMap()")
    }

    @Test
    fun verifyNullaryResolvingToStringDoubleMap() {
        executeTest("verifyNullaryResolvingToStringDoubleMap()")
    }

    @Test
    fun verifyNullaryResolvingToStringStructMap() {
        executeTest("verifyNullaryResolvingToStringStructMap()")
    }

    // endregion

    // region unary parameters

    @Test
    fun verifyUnaryIntResolvingToInt() {
        executeTest("verifyUnaryIntResolvingToInt()")
    }

    @Test
    fun verifyUnaryDoubleResolvingToDouble() {
        executeTest("verifyUnaryDoubleResolvingToDouble()")
    }

    @Test
    fun verifyUnaryStringResolvingToInt() {
        executeTest("verifyUnaryStringResolvingToInt()")
    }

    @Test
    fun verifyUnaryStructResolvingToJsonString() {
        executeTest("verifyUnaryStructResolvingToJsonString()")
    }

    @Test
    fun verifyUnaryDateWrapperResolvingToJsonString() {
        executeTest("verifyUnaryDateWrapperResolvingToJsonString()")
    }

    @Test
    fun verifyUnaryStringListResolvingToString() {
        executeTest("verifyUnaryStringListResolvingToString()")
    }

    @Test
    fun verifyUnaryIntListResolvingToString() {
        executeTest("verifyUnaryIntListResolvingToString()")
    }

    @Test
    fun verifyUnaryDoubleListResolvingToString() {
        executeTest("verifyUnaryDoubleListResolvingToString()")
    }

    @Test
    fun verifyUnaryStructListResolvingToString() {
        executeTest("verifyUnaryStructListResolvingToString()")
    }

    @Test
    fun verifyUnaryIntArrayResolvingToString() {
        executeTest("verifyUnaryIntArrayResolvingToString()")
    }

    @Test
    fun verifyUnaryStringStringMapResolvingToString() {
        executeTest("verifyUnaryStringStringMapResolvingToString()")
    }

    @Test
    fun verifyUnaryStringStructMapResolvingToString() {
        executeTest("verifyUnaryStringStructMapResolvingToString()")
    }

    // endregion

    // region callbacks

    @Test
    fun verifyNullaryResolvingToStringCallback() {
        executeTest("verifyNullaryResolvingToStringCallback()")
    }

    @Test
    fun verifyNullaryResolvingToIntCallback() {
        executeTest("verifyNullaryResolvingToIntCallback()")
    }

    @Test
    fun verifyNullaryResolvingToNullableIntCallback() {
        executeTest("verifyNullaryResolvingToNullableIntCallback()")
    }

    @Test
    fun verifyNullaryResolvingToLongCallback() {
        executeTest("verifyNullaryResolvingToLongCallback()")
    }

    @Test
    fun verifyNullaryResolvingToDoubleCallback() {
        executeTest("verifyNullaryResolvingToDoubleCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStructCallback() {
        executeTest("verifyNullaryResolvingToStructCallback()")
    }

    @Test
    fun verifyNullaryResolvingToDateWrapperCallback() {
        executeTest("verifyNullaryResolvingToDateWrapperCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringListCallback() {
        executeTest("verifyNullaryResolvingToStringListCallback()")
    }

    @Test
    fun verifyNullaryResolvingToIntListCallback() {
        executeTest("verifyNullaryResolvingToIntListCallback()")
    }

    @Test
    fun verifyNullaryResolvingToDoubleListCallback() {
        executeTest("verifyNullaryResolvingToDoubleListCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStructListCallback() {
        executeTest("verifyNullaryResolvingToStructListCallback()")
    }

    @Test
    fun verifyNullaryResolvingToIntArrayCallback() {
        executeTest("verifyNullaryResolvingToIntArrayCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringStringMapCallback() {
        executeTest("verifyNullaryResolvingToStringStringMapCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringIntMapCallback() {
        executeTest("verifyNullaryResolvingToStringIntMapCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringDoubleMapCallback() {
        executeTest("verifyNullaryResolvingToStringDoubleMapCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringStructMapCallback() {
        executeTest("verifyNullaryResolvingToStringStructMapCallback()")
    }

    @Test
    fun verifyNullaryResolvingToStringIntCallback() {
        executeTest("verifyNullaryResolvingToStringIntCallback()")
    }

    @Test
    fun verifyNullaryResolvingToIntStructCallback() {
        executeTest("verifyNullaryResolvingToIntStructCallback()")
    }

    @Test
    fun verifyUnaryIntResolvingToIntCallback() {
        executeTest("verifyUnaryIntResolvingToIntCallback()")
    }

    @Test
    fun verifyBinaryIntDoubleResolvingToIntDoubleCallback() {
        executeTest("verifyBinaryIntDoubleResolvingToIntDoubleCallback()")
    }

    @Test
    fun verifyBinaryIntResolvingIntCallbackReturnsInt() {
        executeTest("verifyBinaryIntResolvingIntCallbackReturnsInt()")
    }

    // endregion

    // region event publishing

    @Test
    fun verifyEventPublishing() {
        expectPlugin.testReady.withTimeoutInSeconds(30) {

            // reset plugin
            expectPlugin.reset()

            // subscribe to events
            runOnUiThread { webView.evaluateJavascript("subscribeToStructEvent()") {} }

            // wait for ready
            expectPlugin.testReady.withTimeoutInSeconds(30) {

                // publish event
                testPlugin.publishEvent(StructEvent(TestStruct()))

                // ensure we received the event
                assertThat(expectPlugin.testFinished.await(30, TimeUnit.SECONDS)).isTrue()
                assertThat(expectPlugin.passed).isTrue()

                // reset plugin
                expectPlugin.reset()

                // publish another event
                testPlugin.publishEvent(StructEvent(TestStruct()))

                // ensure we received the event
                assertThat(expectPlugin.testFinished.await(30, TimeUnit.SECONDS)).isTrue()
                assertThat(expectPlugin.passed).isTrue()

                // reset plugin
                expectPlugin.reset()

                // unsubscribe
                runOnUiThread { webView.evaluateJavascript("unsubscribeFromStructEvent()") {} }

                // wait for ready
                expectPlugin.testReady.withTimeoutInSeconds(30) {

                    // publish event
                    testPlugin.publishEvent(StructEvent(TestStruct()))

                    // make sure we don't get a test finished callback
                    assertThat(expectPlugin.testFinished.await(5, TimeUnit.SECONDS)).isFalse()
                }
            }
        }
    }

    // endregion

    // region exceptions

    @Test
    fun verifyPromiseResolvesWithNonEncodableException() {
        executeTest("verifyPromiseResolvesWithNonEncodableException()")
    }

    @Test
    fun verifyPromiseResolvesWithEncodableException1() {
        executeTest("verifyPromiseResolvesWithEncodableException1()")
    }

    @Test
    fun verifyPromiseResolvesWithEncodableException2() {
        executeTest("verifyPromiseResolvesWithEncodableException2()")
    }

    // endregion

    // region parameter errors

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyStringDecoderRejectsInt() {
        executeTest("verifyStringDecoderRejectsInt()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyStringDecoderRejectsBool() {
        executeTest("verifyStringDecoderRejectsBool()")
    }

    @Test
    fun testVerifyStringDecoderRejectsNull() {
        executeTest("verifyStringDecoderRejectsNull()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyStringDecoderRejectsUndefined() {
        executeTest("verifyStringDecoderRejectsUndefined()")
    }

    @Test
    fun testVerifyStringDecoderResolvesStringNull() {
        executeTest("verifyStringDecoderResolvesStringNull()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyNumberDecoderRejectsString() {
        executeTest("verifyNumberDecoderRejectsString()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyNumberDecoderRejectsObject() {
        executeTest("verifyNumberDecoderRejectsObject()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyNumberDecoderRejectsNull() {
        executeTest("verifyNumberDecoderRejectsNull()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyNumberDecoderRejectsUndefined() {
        executeTest("verifyNumberDecoderRejectsUndefined()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyBoolDecoderRejectsString() {
        executeTest("verifyBoolDecoderRejectsString()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyBoolDecoderRejectsObject() {
        executeTest("verifyBoolDecoderRejectsObject()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyBoolDecoderRejectsNull() {
        executeTest("verifyBoolDecoderRejectsNull()")
    }

    @Ignore("Currently not possible on Android - W-8067673")
    @Test
    fun testVerifyBoolDecoderRejectsUndefined() {
        executeTest("verifyBoolDecoderRejectsUndefined()")
    }

    @Test
    fun testVerifyDictionaryDecoderRejectsString() {
        executeTest("verifyDictionaryDecoderRejectsString()")
    }

    @Test
    fun testVerifyDictionaryDecoderRejectsInt() {
        executeTest("verifyDictionaryDecoderRejectsInt()")
    }

    @Test
    fun testVerifyDictionaryDecoderRejectsBool() {
        executeTest("verifyDictionaryDecoderRejectsBool()")
    }

    @Test
    fun testVerifyDictionaryDecoderRejectsNull() {
        executeTest("verifyDictionaryDecoderRejectsNull()")
    }

    @Test
    fun testVerifyDictionaryDecoderRejectsUndefined() {
        executeTest("verifyDictionaryDecoderRejectsUndefined()")
    }

    @Test
    fun testVerifyTestStructDecoderRejectsString() {
        executeTest("verifyTestStructDecoderRejectsString()")
    }

    @Test
    fun testVerifyTestStructDecoderRejectsInt() {
        executeTest("verifyTestStructDecoderRejectsInt()")
    }

    @Test
    fun testVerifyTestStructDecoderRejectsBool() {
        executeTest("verifyTestStructDecoderRejectsBool()")
    }

    @Test
    fun testVerifyTestStructDecoderRejectsNull() {
        executeTest("verifyTestStructDecoderRejectsNull()")
    }

    @Test
    fun testVerifyTestStructDecoderRejectsUndefined() {
        executeTest("verifyTestStructDecoderRejectsUndefined()")
    }

    // endregion

    private fun executeTest(script: String) {
        expectPlugin.testReady.withTimeoutInSeconds(30) {
            runOnUiThread { webView.evaluateJavascript(script) {} }
            assertThat(expectPlugin.testFinished.await(30, TimeUnit.SECONDS)).isTrue()
            assertThat(expectPlugin.passed).isTrue()
        }
    }
}
