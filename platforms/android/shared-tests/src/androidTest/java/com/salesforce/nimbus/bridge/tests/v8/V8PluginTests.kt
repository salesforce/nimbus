//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.tests.v8

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.rule.ActivityTestRule
import com.eclipsesource.v8.V8
import com.google.common.truth.Truth.assertThat
import com.salesforce.k2v8.scope
import com.salesforce.nimbus.bridge.tests.plugin.ExpectPlugin
import com.salesforce.nimbus.bridge.tests.plugin.StructEvent
import com.salesforce.nimbus.bridge.tests.plugin.TestPlugin
import com.salesforce.nimbus.bridge.tests.plugin.TestStruct
import com.salesforce.nimbus.bridge.tests.plugin.v8Binder
import com.salesforce.nimbus.bridge.tests.WebViewActivity
import com.salesforce.nimbus.bridge.v8.bridge
import com.salesforce.nimbus.bridge.v8.V8Bridge
import org.junit.runner.RunWith
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class V8PluginTests {

    private lateinit var v8: V8
    private lateinit var bridge: V8Bridge
    private lateinit var expectPlugin: ExpectPlugin
    private lateinit var testPlugin: TestPlugin

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule(
        WebViewActivity::class.java, false, true)

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()
        expectPlugin = ExpectPlugin()
        testPlugin = TestPlugin()
        bridge = v8.bridge {
            bind { expectPlugin.v8Binder() }
            bind { testPlugin.v8Binder() }
        }
        v8.scope {
            v8.executeScript("shared-tests".js)
            v8.executeScript("__nimbus.plugins.expectPlugin.ready();")
        }
    }

    @After
    fun tearDown() {
        bridge.detach()
        v8.close()
    }

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

    @Test
    fun verifyEventPublishing() {
        v8.scope {

            // wait for ready
            assertThat(expectPlugin.testReady.await(30, TimeUnit.SECONDS)).isTrue()

            // reset plugin
            expectPlugin.reset()

            // subscribe to events
            v8.executeScript("subscribeToStructEvent()")

            // wait for ready
            assertThat(expectPlugin.testReady.await(30, TimeUnit.SECONDS)).isTrue()

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
            v8.executeScript("unsubscribeFromStructEvent()")

            // wait for ready
            assertThat(expectPlugin.testReady.await(30, TimeUnit.SECONDS)).isTrue()

            // publish event
            testPlugin.publishEvent(StructEvent(TestStruct()))

            // make sure we don't get a test finished callback
            assertThat(expectPlugin.testFinished.await(5, TimeUnit.SECONDS)).isFalse()
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

    private fun executeTest(function: String) {
        assertThat(expectPlugin.testReady.await(30, TimeUnit.SECONDS)).isTrue()
        v8.scope { v8.executeScript(function) }
        assertThat(expectPlugin.testFinished.await(30, TimeUnit.SECONDS)).isTrue()
        assertThat(expectPlugin.passed).isTrue()
    }
}

private val String.js
    get() = ApplicationProvider.getApplicationContext<Application>()
        .resources.assets.open("test-www/$this.js").bufferedReader().use { it.readText() }
