//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonConfiguration
import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap

class PrimitiveJSONEncodable(val value: Any) : JSONEncodable {
    private val stringifiedValue: String

    init {
        val jsonObject = JSONObject()
        jsonObject.put("", value)
        stringifiedValue = jsonObject.toString()
    }

    override fun stringify(): String {
        return stringifiedValue
    }
}

/**
 * A [JSONEncodable] wrapper around an object that is [Serializable] and serialized using a
 * [KSerializer]
 */
class KotlinJSONEncodable<T>(private val value: T, private val serializer: KSerializer<T>) : JSONEncodable {
    override fun stringify(): String {
        return Json(JsonConfiguration.Stable).stringify(serializer, value)
    }
}

inline fun <reified K, reified V> hashMapFromJSON(jsonString: String): HashMap<K, V> {
    val json = JSONObject(jsonString)
    val result = HashMap<K, V>()
    json.keys().forEach { key ->
        val value = json[key]
        if (value !is V) {
            throw IllegalArgumentException("Unexpected value type")
        }
        result[key as K] = json[key] as V
    }
    return result
}

inline fun <reified V> arrayFromJSON(jsonString: String): ArrayList<V> {
    val json = JSONArray(jsonString)
    val result = ArrayList<V>()
    for (i in 0 until json.length()) {
        val value = json[i]
        if (value !is V) {
            throw java.lang.IllegalArgumentException("Unexpected value type")
        }
        result.add(value as V)
    }
    return result
}

// Some helpers for primitive types
fun String.toJSONEncodable(): JSONEncodable {
    return PrimitiveJSONEncodable(this)
}

fun Boolean.toJSONEncodable(): JSONEncodable {
    return PrimitiveJSONEncodable(this)
}

fun Int.toJSONEncodable(): JSONEncodable {
    return PrimitiveJSONEncodable(this)
}

fun Long.toJSONEncodable(): JSONEncodable {
    return PrimitiveJSONEncodable(this)
}

fun Double.toJSONEncodable(): JSONEncodable {
    // Comparing NaN requires a different way
    // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
    if (this == Double.NEGATIVE_INFINITY || this == Double.POSITIVE_INFINITY || this.equals(Double.NaN as Number)) {
        throw IllegalArgumentException("Double value should be finite.")
    } else {
        return PrimitiveJSONEncodable(this)
    }
}
