//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.rule.ActivityTestRule
import com.eclipsesource.v8.V8
import com.google.common.truth.Truth.assertThat
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import com.salesforce.nimbus.k2v8.scope
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonConfiguration
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests the plugin integration with the [V8Bridge].
 */
@RunWith(AndroidJUnit4::class)
class V8PluginTests {

    private lateinit var v8: V8
    private lateinit var expectation: ExpectationPlugin
    private lateinit var bridge: V8Bridge

    @Serializable
    data class SerializableClass(
        val string: String = "String",
        val integer: Int = 1,
        val double: Double = 2.0
    ) {
        override fun toString(): String {
            return "$string, $integer, $double"
        }
    }

    @PluginOptions(name = "test")
    class TestPlugin : Plugin {

        // region non-void return values

        @BoundMethod
        fun returnsInt(): Int {
            return 5
        }

        @BoundMethod
        fun returnsDouble(): Double {
            return 10.0
        }

        @BoundMethod
        fun returnsString(): String {
            return "aString"
        }

        @BoundMethod
        fun returnsSerializable(): SerializableClass {
            return SerializableClass()
        }

        @BoundMethod
        fun returnsIntList(): List<Int> {
            return listOf(1, 2, 3)
        }

        @BoundMethod
        fun returnsDoubleList(): List<Double> {
            return listOf(4.0, 5.0, 6.0)
        }

        @BoundMethod
        fun returnsStringList(): List<String> {
            return listOf("1", "2", "3")
        }

        @BoundMethod
        fun returnsSerializableList(): List<SerializableClass> {
            return listOf(
                SerializableClass("1", 1, 1.0),
                SerializableClass("2", 2, 2.0),
                SerializableClass("3", 3, 3.0)
            )
        }

        @BoundMethod
        fun returnsStringStringMap(): Map<String, String> {
            return mapOf("key1" to "value1", "key2" to "value2", "key3" to "value3")
        }

        @BoundMethod
        fun returnsStringIntMap(): Map<String, Int> {
            return mapOf("key1" to 1, "key2" to 2, "key3" to 3)
        }

        @BoundMethod
        fun returnsStringDoubleMap(): Map<String, Double> {
            return mapOf("key1" to 1.0, "key2" to 2.0, "key3" to 3.0)
        }

        @BoundMethod
        fun returnsStringSerializableMap(): Map<String, SerializableClass> {
            return mapOf(
                "key1" to SerializableClass("1", 1, 1.0),
                "key2" to SerializableClass("2", 2, 2.0),
                "key3" to SerializableClass("3", 3, 3.0)
            )
        }

        // region parameters

        @BoundMethod
        fun intParamReturnsInt(param: Int): Int {
            return param + 1
        }

        @BoundMethod
        fun doubleParamReturnsDouble(param: Double): Double {
            return param * 2
        }

        @BoundMethod
        fun stringParamReturnsStringLength(param: String): Int {
            return param.length
        }

        @BoundMethod
        fun serializableParamReturnsJson(param: SerializableClass): String {
            return Json(JsonConfiguration.Stable).stringify(SerializableClass.serializer(), param)
        }

        @BoundMethod
        fun stringListParamReturnsJoinedString(param: List<String>): String {
            return param.joinToString(separator = ", ")
        }

        @BoundMethod
        fun intListParamReturnsJoinedString(param: List<Int>): String {
            return param.joinToString(separator = ", ")
        }

        @BoundMethod
        fun doubleListParamReturnsJoinedString(param: List<Double>): String {
            return param.joinToString(separator = ", ")
        }

        @BoundMethod
        fun serializableListParamReturnsJoinedString(param: List<SerializableClass>): String {
            return param.joinToString(separator = ", ")
        }

        @BoundMethod
        fun stringStringMapParamReturnsJoinedString(param: Map<String, String>): String {
            return param.map { "${it.key}, ${it.value}" }.joinToString(separator = ", ")
        }

        @BoundMethod
        fun stringSerializableMapParamReturnsJoinedString(param: Map<String, SerializableClass>): String {
            return param.map { "${it.key}, ${it.value}" }.joinToString(separator = ", ")
        }

        // endregion

        // endregion

        // region callbacks

        @BoundMethod
        fun stringCallback(callback: (String) -> Unit) {
            callback("param0")
        }

        @BoundMethod
        fun intCallback(callback: (Int) -> Unit) {
            callback(1)
        }

        @BoundMethod
        fun longCallback(callback: (Long) -> Unit) {
            callback(2L)
        }

        @BoundMethod
        fun doubleCallback(callback: (Double) -> Unit) {
            callback(3.0)
        }

        @BoundMethod
        fun serializableCallback(callback: (SerializableClass) -> Unit) {
            callback(SerializableClass())
        }

        @BoundMethod
        fun stringListCallback(callback: (List<String>) -> Unit) {
            callback(listOf("1", "2", "3"))
        }

        @BoundMethod
        fun intListCallback(callback: (List<Int>) -> Unit) {
            callback(listOf(1, 2, 3))
        }

        @BoundMethod
        fun doubleListCallback(callback: (List<Double>) -> Unit) {
            callback(listOf(1.0, 2.0, 3.0))
        }

        @BoundMethod
        fun serializableListCallback(callback: (List<SerializableClass>) -> Unit) {
            callback(
                listOf(
                    SerializableClass("1", 1, 1.0),
                    SerializableClass("2", 2, 2.0),
                    SerializableClass("3", 3, 3.0)
                )
            )
        }

        @BoundMethod
        fun stringStringMapCallback(callback: (Map<String, String>) -> Unit) {
            callback(
                mapOf(
                    "key1" to "value1",
                    "key2" to "value2",
                    "key3" to "value3"
                )
            )
        }

        @BoundMethod
        fun stringIntMapCallback(callback: (Map<String, Int>) -> Unit) {
            callback(
                mapOf(
                    "1" to 1,
                    "2" to 2,
                    "3" to 3
                )
            )
        }

        @BoundMethod
        fun stringDoubleMapCallback(callback: (Map<String, Double>) -> Unit) {
            callback(
                mapOf(
                    "1.0" to 1.0,
                    "2.0" to 2.0,
                    "3.0" to 3.0
                )
            )
        }

        @BoundMethod
        fun stringSerializableMapCallback(callback: (Map<String, SerializableClass>) -> Unit) {
            callback(
                mapOf(
                    "1" to SerializableClass("1", 1, 1.0),
                    "2" to SerializableClass("2", 2, 2.0),
                    "3" to SerializableClass("3", 3, 3.0)
                )
            )
        }

        @BoundMethod
        fun stringIntCallback(callback: (String, Int) -> Unit) {
            callback("param0", 1)
        }

        @BoundMethod
        fun intSerializableCallback(callback: (Int, SerializableClass) -> Unit) {
            callback(2, SerializableClass())
        }

        @BoundMethod
        fun doubleIntSerializableCallback(callback: (Int, Double, SerializableClass) -> Unit) {
            callback(3, 4.0, SerializableClass())
        }

        @BoundMethod
        fun intParamIntCallback(param: Int, callback: (Int) -> Unit) {
            callback(param + 1)
        }

        @BoundMethod
        fun intDoubleParamIntCallback(param0: Int, param1: Double, callback: (Int, Double) -> Unit) {
            callback(param0 + 1, param1 * 2)
        }
    }

    @Rule
    @JvmField
    val activityRule: ActivityTestRule<WebViewActivity> = ActivityTestRule(
        WebViewActivity::class.java, false, true)

    @Before
    fun setUp() {
        expectation = ExpectationPlugin()
        v8 = V8.createV8Runtime()
        bridge = V8Bridge().apply {
            add(ExpectationPluginV8Binder(expectation))
            add(TestPluginV8Binder(TestPlugin()))
            attach(v8)
        }
    }

    // region non-void return types

    @Test
    fun returnsInt() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 5) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsInt().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsDouble() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 10.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsDouble().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 'aString') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsString().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsSerializable() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result.string !== 'String' ||
                    result.integer !== 1 ||
                    result.double !== 2.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsSerializable().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsIntList() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result[0] !== 1 || 
                    result[1] !== 2 ||
                    result[2] !== 3) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsIntList().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsDoubleList() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result[0] !== 4.0 || 
                    result[1] !== 5.0 ||
                    result[2] !== 6.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsDoubleList().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsStringList() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result[0] !== '1' || 
                    result[1] !== '2' ||
                    result[2] !== '3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsStringList().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsSerializableList() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result[0].string !== '1' ||
                    result[0].integer !== 1 ||
                    result[0].double !== 1.0 ||
                    result[1].string !== '2' ||
                    result[1].integer !== 2 ||
                    result[1].double !== 2.0 ||
                    result[2].string !== '3' ||
                    result[2].integer !== 3 ||
                    result[2].double !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsSerializableList().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsStringStringMap() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result['key1'] !== 'value1' || 
                    result['key2'] !== 'value2' ||
                    result['key3'] !== 'value3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsStringStringMap().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsStringIntMap() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result['key1'] !== 1 || 
                    result['key2'] !== 2 ||
                    result['key3'] !== 3) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsStringIntMap().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsStringDoubleMap() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result['key1'] !== 1.0 || 
                    result['key2'] !== 2.0 ||
                    result['key3'] !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsStringDoubleMap().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun returnsStringSerializableMap() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result['key1'].string !== '1' ||
                    result['key1'].integer !== 1 ||
                    result['key1'].double !== 1.0 ||
                    result['key2'].string !== '2' ||
                    result['key2'].integer !== 2 ||
                    result['key2'].double !== 2.0 ||
                    result['key3'].string !== '3' ||
                    result['key3'].integer !== 3 ||
                    result['key3'].double !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.returnsStringSerializableMap().then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    // region non-callback parameter types

    @Test
    fun intParamReturnsInt() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 6) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.intParamReturnsInt(5).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun doubleParamReturnsDouble() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 10.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.doubleParamReturnsDouble(5.0).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringParamReturnsStringLength() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 11) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.stringParamReturnsStringLength('some string').then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun serializableParamReturnsJson() = v8.scope {
        val testScript = """
            function checkResult(result) {
                let json = JSON.parse(result);
                if (json['string'] !== 'some string' ||
                    json['integer'] !== 5 ||
                    json['double'] !== 10.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            let param = {
                "string": "some string",
                "integer": 5,
                "double": 10.0
            };
            __nimbus.plugins.test.serializableParamReturnsJson(param).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringListParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== '1, 2, 3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.stringListParamReturnsJoinedString(['1','2','3']).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intListParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== '4, 5, 6') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.intListParamReturnsJoinedString([4, 5, 6]).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun doubleListParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== '7.0, 8.0, 9.0') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            __nimbus.plugins.test.doubleListParamReturnsJoinedString([7.0, 8.0, 9.0]).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun serializableListParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 'test1, 1, 1.0, test2, 2, 2.0, test3, 3, 3.0') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            let param = [
                {
                    string: "test1",
                    integer: 1,
                    double: 1.0
                },
                {
                    string: "test2",
                    integer: 2,
                    double: 2.0
                },
                {
                    string: "test3",
                    integer: 3,
                    double: 3.0
                }
            ];
            __nimbus.plugins.test.serializableListParamReturnsJoinedString(param).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringStringMapParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 'key1, value1, key2, value2, key3, value3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            let map = [];
            map['key1'] = 'value1';
            map['key2'] = 'value2';
            map['key3'] = 'value3';
            __nimbus.plugins.test.stringStringMapParamReturnsJoinedString(map).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringSerializableMapParamReturnsJoinedString() = v8.scope {
        val testScript = """
            function checkResult(result) {
                if (result !== 'key1, string1, 1, 1.0, key2, string2, 2, 2.0, key3, string3, 3, 3.0') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
            }
            let map = [];
            map['key1'] = {
                string: "string1",
                integer: 1,
                double: 1.0
            };
            map['key2'] = {
                string: "string2",
                integer: 2,
                double: 2.0
            };
            map['key3'] = {
                string: "string3",
                integer: 3,
                double: 3.0
            };
            __nimbus.plugins.test.stringSerializableMapParamReturnsJoinedString(map).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    // endregion

    // endregion

    // region callbacks

    @Test
    fun stringCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result !== 'param0') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result !== 1) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.intCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun longCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result !== 2) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.longCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun doubleCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.doubleCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun serializableCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result.string !== 'String' ||
                    result.integer !== 1 ||
                    result.double !== 2.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.serializableCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringListCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result[0] !== '1' ||
                    result[1] !== '2' ||
                    result[2] !== '3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringListCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intListCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result[0] !== 1 ||
                    result[1] !== 2 ||
                    result[2] !== 3) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.intListCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun doubleListCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result[0] !== 1.0 ||
                    result[1] !== 2.0 ||
                    result[2] !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.doubleListCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun serializableListCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result[0].string !== '1' ||
                    result[0].integer !== 1 ||
                    result[0].double !== 1.0 ||
                    result[1].string !== '2' ||
                    result[1].integer !== 2 ||
                    result[1].double !== 2.0 ||
                    result[2].string !== '3' ||
                    result[2].integer !== 3 ||
                    result[2].double !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.serializableListCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringStringMapCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result['key1'] !== 'value1' ||
                    result['key2'] !== 'value2' ||
                    result['key3'] !== 'value3') {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringStringMapCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringIntMapCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result['1'] !== 1 ||
                    result['2'] !== 2 ||
                    result['3'] !== 3) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringIntMapCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringDoubleMapCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result['1.0'] !== 1.0 ||
                    result['2.0'] !== 2.0 ||
                    result['3.0'] !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringDoubleMapCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringSerializableMapCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result['1'].string !== '1' ||
                    result['1'].integer !== 1 ||
                    result['1'].double !== 1.0 ||
                    result['2'].string !== '2' ||
                    result['2'].integer !== 2 ||
                    result['2'].double !== 2.0 ||
                    result['3'].string !== '3' ||
                    result['3'].integer !== 3 ||
                    result['3'].double !== 3.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringSerializableMapCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun stringIntCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(string, int) {
                if (string !== 'param0' ||
                    int != 1) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.stringIntCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intSerializableCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(int, serializable) {
                if (int !== 2 ||
                    serializable.string !== 'String' ||
                    serializable.integer !== 1 ||
                    serializable.double !== 2.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.intSerializableCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun doubleIntSerializableCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(int, double, serializable) {
                if (int !== 3 ||
                    double !== 4.0 ||
                    serializable.string !== 'String' ||
                    serializable.integer !== 1 ||
                    serializable.double !== 2.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.doubleIntSerializableCallback(callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intParamIntCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(result) {
                if (result !== 4) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.intParamIntCallback(3, callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    @Test
    fun intDoubleParamIntCallback() = v8.scope {
        val testScript = """
            function checkResult() {
            }
            function callbackResult(int, double) {
                if (int !== 4 ||
                    double != 4.0) {
                    __nimbus.plugins.expect.fail();
                    return;
                }
                __nimbus.plugins.expect.pass();
                return;
            }
            __nimbus.plugins.test.intDoubleParamIntCallback(3, 2.0, callbackResult).then(checkResult);
        """.trimIndent()
        v8.executeScript(testScript)
        assertThat(expectation.passed).isTrue()
    }

    // endregion

}
