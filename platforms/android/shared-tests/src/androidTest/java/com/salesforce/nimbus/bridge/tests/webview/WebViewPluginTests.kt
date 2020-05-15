package com.salesforce.nimbus.bridge.tests.webview

import android.webkit.WebView
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import androidx.test.rule.ActivityTestRule
import com.google.common.truth.Truth.assertThat
import com.salesforce.nimbus.bridge.tests.WebViewActivity
import com.salesforce.nimbus.bridge.tests.plugin.ExpectPlugin
import com.salesforce.nimbus.bridge.tests.plugin.TestPlugin
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
import org.junit.runner.RunWith
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class WebViewPluginTests {

    private lateinit var webView: WebView
    private lateinit var bridge: WebViewBridge
    private lateinit var expectPlugin: ExpectPlugin

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule(
        WebViewActivity::class.java, false, true)

    @Before
    fun setUp() {
        webView = activityRule.activity.webView
        expectPlugin = ExpectPlugin()
        runOnUiThread {
            bridge = webView.bridge {
                bind { expectPlugin.webViewBinder() }
                bind { TestPlugin().webViewBinder() }
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
    fun verifyNullaryResolvingToDoubleIntStructCallback() {
        executeTest("verifyNullaryResolvingToDoubleIntStructCallback()")
    }

    @Test
    fun verifyUnaryIntResolvingToIntCallback() {
        executeTest("verifyUnaryIntResolvingToIntCallback()")
    }

    @Test
    fun verifyBinaryIntDoubleResolvingToIntDoubleCallback() {
        executeTest("verifyBinaryIntDoubleResolvingToIntDoubleCallback()")
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
