//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.booleans.shouldBeTrue
import io.kotest.matchers.shouldBe
import io.kotest.property.checkAll
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class PrimitiveJSONEncodableTests : StringSpec({
    "listFromJSON<String>" {
        checkAll<String, String, String> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                ${JSONObject.quote(value3)}
            ]
            """.trimIndent()

            val array = listFromJSON<String>(json)
            value1.shouldBe(array[0])
            value2.shouldBe(array[1])
            value3.shouldBe(array[2])
        }
    }

    "listFromJSON<Int>" {
        checkAll<Int, Int, Int> { value1, value2, value3 ->
            val json = """
            [
                $value1,
                $value2,
                $value3
            ]
            """.trimIndent()

            val array = listFromJSON<Int>(json)
            value1.shouldBe(array[0])
            value2.shouldBe(array[1])
            value3.shouldBe(array[2])
        }
    }

    "listFromJSON<Any>" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                $value3
            ]
            """.trimIndent()

            val array = listFromJSON<Any>(json)
            value1.shouldBe(array[0] as String)
            value2.shouldBe(array[1] as String)
            value3.shouldBe(array[2] as Int)
        }
    }

    "listFromJSON<String> from Int throws" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                $value3
            ]
            """.trimIndent()

            shouldThrow<JSONException> {
                listFromJSON<String>(json)
            }
        }
    }

    "mapFromJSON<String, String>" {
        checkAll<String, String, String> { value1, value2, value3 ->
            val json = """
            {
                "key1": ${JSONObject.quote(value1)},
                "key2": ${JSONObject.quote(value2)},
                "key3": ${JSONObject.quote(value3)}
            }
            """.trimIndent()

            val map = mapFromJSON<String, String>(json)
            value1.shouldBe(map["key1"])
            value2.shouldBe(map["key2"])
            value3.shouldBe(map["key3"])
        }
    }

    "mapFromJSON<String, Int>" {
        checkAll<Int, Int, Int> { value1, value2, value3 ->
            val json = """
            {
                "key1": $value1,
                "key2": $value2,
                "key3": $value3
            }
            """.trimIndent()

            val map = mapFromJSON<String, Int>(json)
            value1.shouldBe(map["key1"] as Int)
            value2.shouldBe(map["key2"] as Int)
            value3.shouldBe(map["key3"] as Int)
        }
    }

    "mapFromJSON<String, Any>" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
            {
                "key1": ${JSONObject.quote(value1)},
                "key2": ${JSONObject.quote(value2)},
                "key3": $value3
            }
            """.trimIndent()

            val map = mapFromJSON<String, Any>(json)
            value1.shouldBe(map["key1"] as String)
            value2.shouldBe(map["key2"] as String)
            value3.shouldBe(map["key3"] as Int)
        }
    }

    "mapFromJSON<String, String> from Int throws" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
                    {
                        "key1": ${JSONObject.quote(value1)},
                        "key2": ${JSONObject.quote(value2)},
                        "key3": $value3
                    }
            """.trimIndent()

            shouldThrow<JSONException> {
                mapFromJSON<String, String>(json)
            }
        }
    }

    "arrayFromJSON<String>" {
        checkAll<String, String, String> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                ${JSONObject.quote(value3)}
            ]
            """.trimIndent()

            val array = arrayFromJSON<String>(json)
            value1.shouldBe(array[0])
            value2.shouldBe(array[1])
            value3.shouldBe(array[2])
        }
    }

    "arrayFromJSON<Int>" {
        checkAll<Int, Int, Int> { value1, value2, value3 ->
            val json = """
                [
                    $value1,
                    $value2,
                    $value3
                ]
            """.trimIndent()

            val array = arrayFromJSON<Int>(json)
            value1.shouldBe(array[0])
            value2.shouldBe(array[1])
            value3.shouldBe(array[2])
        }
    }

    "arrayFromJSON<Any>" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                $value3
            ]
            """.trimIndent()

            val array = arrayFromJSON<Any>(json)
            value1.shouldBe(array[0] as String)
            value2.shouldBe(array[1] as String)
            value3.shouldBe(array[2] as Int)
        }
    }

    "arrayFromJSON<String> from Int throws" {
        checkAll<String, String, Int> { value1, value2, value3 ->
            val json = """
            [
                ${JSONObject.quote(value1)},
                ${JSONObject.quote(value2)},
                $value3
            ]
            """.trimIndent()

            shouldThrow<JSONException> {
                arrayFromJSON<String>(json)
            }
        }
    }

    "List<Int> toJsonEncodable" {
        checkAll<List<Int>> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonArray = JSONArray(jsonString)
            a.indices.forEach {
                a[it].shouldBe(jsonArray[it])
            }
        }
    }

    "List<String> toJSONEncodable.toJSONEncodable" {
        checkAll<List<String>> { a ->
            val jsonString = a.map { it.toJSONEncodable() }.toJSONEncodable().encode()
            val jsonArray = JSONArray(jsonString)
            a.indices.forEach {
                a[it].shouldBe(JSONObject(jsonArray[it] as String).get(""))
            }
        }
    }

    "Map<String, String> toJSONEncodable" {
        checkAll<Map<String, String>> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            a.entries.forEach { (key, value) ->
                value.shouldBe(jsonObject[key])
            }
        }
    }

    "Map<String, String> toJSONEncodable.toJSONEncodable" {
        checkAll<Map<String, String>> { a ->
            val jsonString = a.mapValues { it.value.toJSONEncodable() }.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            a.entries.forEach { (key, value) ->
                value.shouldBe(JSONObject(jsonObject[key] as String).get(""))
            }
        }
    }

    "Array<Int> toJSONEncodable" {
        checkAll<List<Int>> { a ->
            val jsonString = a.toTypedArray().toJSONEncodable().encode()
            val jsonArray = JSONArray(jsonString)
            a.indices.forEach {
                a[it].shouldBe(jsonArray[it])
            }
        }
    }

    "List<String> toJSONEncodable.toArray.toJSONEncodable" {
        checkAll<List<String>> { a ->
            val jsonString = a.map { it.toJSONEncodable() }.toTypedArray().toJSONEncodable().encode()
            val jsonArray = JSONArray(jsonString)
            a.indices.all { i -> a[i] == JSONObject(jsonArray[i] as String).get("") }
        }
    }

    "Double toJSONEncodable" {
        checkAll<Double> { a ->
            // Comparing NaN requires a different way
            // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
            if (a == Double.POSITIVE_INFINITY || a == Double.NEGATIVE_INFINITY || a.equals(Double.NaN as Number)) {
                var hasSameExceptionMessage = false
                try {
                    a.toJSONEncodable()
                } catch (e: Exception) {
                    hasSameExceptionMessage = e.message.equals("Double value should be finite.")
                }
                hasSameExceptionMessage.shouldBeTrue()
            } else {
                val jsonString = a.toJSONEncodable().encode()
                val jsonObject = JSONObject(jsonString)
                val value = jsonObject.get("")
                if (a != value) {
                    // If the generated value that is, for example, like 1.0, the fractional values
                    // are dropped by JSON serializer and returns a whole number.  So the check here seeks
                    // if the whole number comparison, assuming that fractional part was 0, would be equal.
                    val convertedToInt = a.toInt()
                    convertedToInt.shouldBe(value ?: false)
                }
            }
        }
    }

    "Int toJSONEncodable" {
        checkAll<Int> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a.shouldBe(value)
        }
    }

    "Boolean toJSONEncodable" {
        checkAll<Boolean> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a.shouldBe(value)
        }
    }

    "Long toJSONEncodable" {
        checkAll<Long> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a.shouldBe(value)
        }
    }

    "String toJSONEncodable" {
        checkAll<String> { a ->
            val jsonString = a.toJSONEncodable().encode()
            val jsonObject = JSONObject(jsonString)
            val value = jsonObject.get("")
            a.shouldBe(value)
        }
    }
})
