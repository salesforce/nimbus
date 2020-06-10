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
import kotlin.reflect.KClass

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
inline fun <reified K, reified V : Any> mapFromJSON(jsonString: String): Map<K, V> {
    val json = JSONObject(jsonString)
    val result = HashMap<K, V>()
    json.keys().forEach { key ->
        @Suppress("RemoveExplicitTypeArguments")
        result[key as K] = extractValueFromJSONObject<V>(V::class, json, key)
    }
    return result
}

/**
 * Creates a [List] from a JSON string.
 */
inline fun <reified V : Any> listFromJSON(jsonString: String): List<V> {
    val json = JSONArray(jsonString)
    val result = ArrayList<V>()
    for (index in 0 until json.length()) {
        @Suppress("RemoveExplicitTypeArguments")
        result.add(extractValueFromJSONArray<V>(V::class, json, index))
    }
    return result
}

/**
 * Creates an [Array] from a JSON string.
 */
inline fun <reified V : Any> arrayFromJSON(jsonString: String): Array<V> {
    val json = JSONArray(jsonString)
    return Array(json.length()) { index ->
        @Suppress("RemoveExplicitTypeArguments")
        extractValueFromJSONArray<V>(V::class, json, index)
    }
}

/**
 * Extracts a value [V] from the json array at the index specified.
 */
fun <V : Any> extractValueFromJSONArray(kClass: KClass<V>, json: JSONArray, index: Int): V {
    @Suppress("UNCHECKED_CAST")
    return when (kClass) {
        Int::class -> json.getInt(index)
        Double::class -> json.getDouble(index)
        Boolean::class -> json.getBoolean(index)
        Long::class -> json.getLong(index)
        String::class -> json.getString(index)
        else -> {
            val value = json.get(index)
            if (value is JSONObject) mapFromJSON<String, Any>(value.toString())
            else value
        }
    } as V
}

/**
 * Extracts a value [V] from the json object with the key specified.
 */
fun <V : Any> extractValueFromJSONObject(kClass: KClass<V>, json: JSONObject, key: String): V {
    @Suppress("UNCHECKED_CAST")
    return when (kClass) {
        Int::class -> json.getInt(key)
        Double::class -> json.getDouble(key)
        Boolean::class -> json.getBoolean(key)
        Long::class -> json.getLong(key)
        String::class -> json.getString(key)
        else -> {
            val value = json.get(key)
            if (value is JSONObject) mapFromJSON<String, Any>(value.toString())
            else value
        }
    } as V
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
