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

class PrimitiveJSONSerializable(val value: Any) :
    JSONSerializable {
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
 * A [JSONSerializable] wrapper around an object that is [Serializable] and serialized using a
 * [KSerializer]
 */
class KotlinJSONSerializable<T>(private val value: T, private val serializer: KSerializer<T>): JSONSerializable {
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
fun String.toJSONSerializable(): JSONSerializable {
    return PrimitiveJSONSerializable(this)
}

fun Boolean.toJSONSerializable(): JSONSerializable {
    return PrimitiveJSONSerializable(this)
}

fun Int.toJSONSerializable(): JSONSerializable {
    return PrimitiveJSONSerializable(this)
}

fun Long.toJSONSerializable(): JSONSerializable {
    return PrimitiveJSONSerializable(this)
}

fun Double.toJSONSerializable(): JSONSerializable {
    // Comparing NaN requires a different way
    // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
    if (this == Double.NEGATIVE_INFINITY || this == Double.POSITIVE_INFINITY || this.equals(Double.NaN as Number)) {
        throw IllegalArgumentException("Double value should be finite.")
    } else {
        return PrimitiveJSONSerializable(this)
    }
}
