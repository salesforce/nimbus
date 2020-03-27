//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.webview

import com.salesforce.nimbus.JSONSerializable
import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap

// Making this internal so it's not a footgun to consumers
internal class PrimitiveJSONSerializable(val value: Any) :
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

inline fun <reified V> hashMapFromJSON(jsonString: String): HashMap<String, V> {
    val json = JSONObject(jsonString)
    val result = HashMap<String, V>()
    json.keys().forEach { key ->
        val value = json[key]
        if (value !is V) {
            throw IllegalArgumentException("Unexpected value type")
        }
        result[key] = json[key] as V
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
