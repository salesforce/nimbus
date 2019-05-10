//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import io.kotlintest.properties.Gen
import io.kotlintest.properties.forAll
import io.kotlintest.specs.AnnotationSpec
import io.kotlintest.specs.Test
import org.json.JSONObject

class PrimitiveExtensionsTests : AnnotationSpec() {

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
