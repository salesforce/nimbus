package com.salesforce.nimbus.bridge.tests

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.google.common.truth.Truth.assertThat
import com.salesforce.nimbus.bridge.v8.V8Bridge
import com.salesforce.nimbus.bridge.v8.toV8Encodable
import com.salesforce.nimbus.invoke
import com.salesforce.nimbus.k2v8.scope
import kotlinx.serialization.Serializable
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

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

    @Serializable
    data class SomeClass(val someString: String, val someInt: Int)

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()
        v8.executeScript(fixtureScript)
        bridge = V8Bridge().apply { attach(v8) }
    }

    @After
    fun tearDown() {
        bridge.detach()
        v8.close()
    }

    @Test
    fun testInvokePromiseResolvedWithPromise() {
        v8.scope {
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
        v8.scope {
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
        v8.scope {
            withinLatch {
                bridge.invoke("objectFunc", emptyArray(), SomeClass.serializer()) { error, result ->
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
        v8.scope {
            withinLatch {
                bridge.invoke("intAddOneFunc", arrayOf(1.toV8Encodable(v8))) { error, result ->
                    assertThat(error).isNull()
                    assertThat(result).isEqualTo(2)
                    countDown()
                }
            }
        }
    }

    @Test
    fun testInvokePromiseRejected() {
        v8.scope {
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
