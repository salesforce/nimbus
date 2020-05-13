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

    override fun encode(): String {
        return stringifiedValue
    }
}

/**
 * A [JSONEncodable] wrapper around an object that is [Serializable] and serialized using a
 * [KSerializer]
 */
class KotlinJSONEncodable<T>(private val value: T, private val serializer: KSerializer<T>) : JSONEncodable {
    override fun encode(): String {
        return Json(JsonConfiguration.Stable).stringify(serializer, value)
    }
}

/**
 * Creates a [Map] from a JSON string.
 */
inline fun <reified K, reified V> mapFromJSON(jsonString: String): Map<K, V> {
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

/**
 * Creates a [List] from a JSON string.
 */
inline fun <reified V> listFromJSON(jsonString: String): List<V> {
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

/**
 * Creates an [Array] from a JSON string.
 */
@Suppress("USELESS_CAST")
inline fun <reified V> arrayFromJSON(jsonString: String): Array<V> {
    val json = JSONArray(jsonString)
    return Array(json.length()) { index ->
        val value = json[index]
        if (value !is V) {
            throw java.lang.IllegalArgumentException("Unexpected value type")
        }
        value as V
    }
}

/**
 * Converts a [V] typed [List] to a [JSONEncodable].
 */
fun <V> List<V>.toJSONEncodable(): JSONEncodable {
    return object : JSONEncodable {
        override fun encode(): String {
            return JSONArray().apply {
                forEach {
                    if (it is JSONEncodable) {
                        put(it.encode())
                    } else {
                        put(it)
                    }
                }
            }.toString()
        }
    }
}

/**
 * Converts a [String][V] typed [Map] to a [JSONEncodable].
 */
fun <V> Map<String, V>.toJSONEncodable(): JSONEncodable {
    return object : JSONEncodable {
        override fun encode(): String {
            return JSONObject().apply {
                forEach { (key, value) ->
                    if (value is JSONEncodable) {
                        put(key, value.encode())
                    } else {
                        put(key, value)
                    }
                }
            }.toString()
        }
    }
}

/**
 * Converts a [V] typed [Array] to a [JSONEncodable].
 */
fun <V> Array<V>.toJSONEncodable(): JSONEncodable {
    return object : JSONEncodable {
        override fun encode(): String {
            return JSONArray().apply {
                forEach {
                    if (it is JSONEncodable) {
                        put(it.encode())
                    } else {
                        put(it)
                    }
                }
            }.toString()
        }
    }
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
