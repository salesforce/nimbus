//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.tests.v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.google.common.truth.Truth.assertThat
import com.salesforce.nimbus.bridge.tests.withinLatch
import com.salesforce.nimbus.bridge.v8.V8Bridge
import com.salesforce.nimbus.bridge.v8.bridge
import com.salesforce.nimbus.bridge.v8.toV8Encodable
import com.salesforce.nimbus.invoke
import kotlinx.serialization.Serializable
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Tests the [V8Bridge.invoke] function.
 */
@RunWith(AndroidJUnit4::class)
class V8BridgeInvokeTests {

    private lateinit var v8: V8
    private lateinit var bridge: V8Bridge
    private val fixtureScript = """
        function promiseFunc() { return Promise.resolve(42); };
        function intFunc() { return 43; };
        function objectFunc() { return { someString: "Some string", someInt: 5 } };
        function promiseFuncReject() { return Promise.reject("epic fail"); };
        function resolveToVoid() { return Promise.resolve(); }
        function intAddOneFunc(int) { return int + 1; };
    """.trimIndent()

    private lateinit var executorService: ExecutorService

    @Serializable
    data class SomeClass(val someString: String, val someInt: Int)

    @Before
    fun setUp() {
        executorService = Executors.newSingleThreadExecutor()
        v8 = executorService.submit<V8> { V8.createV8Runtime() }.get()
        bridge = v8.bridge(executorService)
        bridge.executeScriptOnExecutor(fixtureScript)
    }

    @After
    fun tearDown() {
        bridge.detach()
    }

    @Test
    fun testInvokePromiseResolvedWithPromise() {
        bridge.executorScope(executorService) {
            withinLatch {
                bridge.invoke("promiseFunc", emptyArray()) { error, result ->
                    assertThat(error).isNull()
                    assertThat(result).isEqualTo(42)
                    countDown()
                }
            }
        }
    }

    @Test
    fun testInvokePromiseResolvedWithInt() {
        bridge.executorScope(executorService) {
            withinLatch {
                bridge.invoke("intFunc", emptyArray()) { error, result ->
                    assertThat(error).isNull()
                    assertThat(result).isEqualTo(43)
                    countDown()
                }
            }
        }
    }

    @Test
    fun testInvokePromiseResolvedWithObject() {
        bridge.executorScope(executorService) {
            withinLatch {
                bridge.invoke(
                    "objectFunc",
                    emptyArray(),
                    SomeClass.serializer()
                ) { error, result ->
                    assertThat(error).isNull()
                    assertThat(result).isNotNull()
                    assertThat(result).isEqualTo(
                        SomeClass(
                            "Some string",
                            5
                        )
                    )
                    countDown()
                }
            }
        }
    }

    @Test
    fun testInvokeWithIntParameterResolvedWithInt() {
        bridge.executorScope(executorService) {
            withinLatch {
                bridge.invoke("intAddOneFunc", arrayOf(1.toV8Encodable(v8, executorService))) { error, result ->
                    assertThat(error).isNull()
                    assertThat(result).isEqualTo(2)
                    countDown()
                }
            }
        }
    }

    @Test
    fun testInvokePromiseRejected() {
        bridge.executorScope(executorService) {
            withinLatch {
                bridge.invoke("promiseFuncReject", emptyArray()) { error, result ->
                    assertThat(error).isEqualTo("epic fail")
                    assertThat(result).isNull()
                    countDown()
                }
            }
        }
    }
}
