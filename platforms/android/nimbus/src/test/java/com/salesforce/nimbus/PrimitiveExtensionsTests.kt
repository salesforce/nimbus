//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import io.kotlintest.properties.Gen
import io.kotlintest.properties.forAll
import io.kotlintest.shouldThrow
import io.kotlintest.specs.AnnotationSpec
import io.kotlintest.specs.Test
import org.json.JSONObject
import org.junit.Assert.assertEquals
import java.lang.IllegalArgumentException

class PrimitiveExtensionsTests : AnnotationSpec() {

    @Test
    fun testArrayFromJSON_String() {
        val json = """
            [
                "value1",
                "value2",
                "value3"
            ]
        """.trimIndent()

        val array = arrayFromJSON(json, String::class.java)
        assertEquals("value1", array[0])
        assertEquals("value2", array[1])
        assertEquals("value3", array[2])
    }

    @Test
    fun testArrayFromJSON_Int() {
        val json = """
            [
                42,
                37,
                13
            ]
        """.trimIndent()

        val array = arrayFromJSON(json, Integer::class.java)
        assertEquals(42, array[0])
        assertEquals(37, array[1])
        assertEquals(13, array[2])
    }

    @Test
    fun testArrayFromJSON_Any() {
        val json = """
            [
                "value1",
                "value2",
                42
            ]
        """.trimIndent()

        val array = arrayFromJSON(json, Object::class.java)
        assertEquals("value1", array[0])
        assertEquals("value2", array[1])
        assertEquals(42, array[2])
    }

    @Test
    fun testArrayFromJSON_String_throws() {
        val json = """
            [
                "value1",
                "value2",
                42
            ]
        """.trimIndent()

        shouldThrow<IllegalArgumentException> {
            arrayFromJSON(json, String::class.java)
        }
    }

    @Test
    fun testHashMapFromJSON_String_String() {
        val json = """
            {
                "key1": "value1",
                "key2": "value2",
                "key3": "value3"
            }
        """.trimIndent()

        val map = hashMapFromJSON(json, String::class.java, String::class.java)
        assertEquals("value1", map["key1"])
        assertEquals("value2", map["key2"])
        assertEquals("value3", map["key3"])
    }

    @Test
    fun testHashMapFromJSON_String_Int() {
        val json = """
            {
                "key1": 42,
                "key2": 37,
                "key3": 13
            }
        """.trimIndent()

        val map = hashMapFromJSON(json, String::class.java, Integer::class.java)
        assertEquals(42, map["key1"])
        assertEquals(37, map["key2"])
        assertEquals(13, map["key3"])
    }

    @Test
    fun testHashMapFromJSON_String_Any() {
        val json = """
            {
                "key1": "value1",
                "key2": "value2",
                "key3": 42
            }
        """.trimIndent()

        val map = hashMapFromJSON(json, String::class.java, Object::class.java)
        assertEquals("value1", map["key1"])
        assertEquals("value2", map["key2"])
        assertEquals(42, map["key3"])
    }

    @Test
    fun testHashMapFromJSON_String_String_throws() {
        val json = """
            {
                "key1": "value1",
                "key2": "value2",
                "key3": 42
            }
        """.trimIndent()

        shouldThrow<IllegalArgumentException> {
            hashMapFromJSON(json, String::class.java, String::class.java)
        }
    }

    @Test
    fun testDoubleToJSON() {
        forAll(Gen.double()) { a ->
            // Comparing NaN requires a different way
            // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
            if (a == Double.POSITIVE_INFINITY || a == Double.NEGATIVE_INFINITY || a.equals(Double.NaN as Number)) {
                var sameExceptionMessage = false
                try {
                    a.toJSONSerializable()
                } catch (e: Exception) {
                    sameExceptionMessage = e.message.equals("Double value should be finite.")
                }
                sameExceptionMessage
            } else {
                val jsonString = a.toJSONSerializable().stringify()
                val jsonObject = JSONObject(jsonString)
                val value = jsonObject.get("")
                if (a == value) {
                    true
                } else {
                    // If the generated value that is, for example, like 1.0, the fractional values
                    // are dropped by JSON serializer and returns a whole number.  So the check here seeks
                    // if the whole number comparison, assuming that fractional part was 0, would be equal.
                    val convertedToInt = a.toInt()
                    convertedToInt == value ?: false
                }
            }
        }
    }

    @Test
    fun testIntToJSON() {
        forAll(Gen.int()) { a ->
            val jsonString = a.toJSONSerializable().stringify()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a == value
        }
    }

    @Test
    fun testBooleanToJSON() {
        forAll(Gen.bool()) { a ->
            val jsonString = a.toJSONSerializable().stringify()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a == value
        }
    }

    @Test
    fun testLongToJSON() {
        forAll(Gen.long()) { a ->
            val jsonString = a.toJSONSerializable().stringify()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a == value
        }
    }

    @Test
    fun testStringToJSON() {
        forAll(Gen.string()) { a ->
            val jsonString = a.toJSONSerializable().stringify()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a == value
        }
    }
}
