//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import org.json.JSONArray
import org.json.JSONObject
import java.util.HashMap

// Making this internal so it's not a footgun to consumers
internal class PrimitiveJSONSerializable(val value: Any) : JSONSerializable {
    val stringifiedValue: String

    init {
        val jsonObject = JSONObject()
        jsonObject.put("", value)
        if (jsonObject.get("") == null) {
            throw IllegalArgumentException("Failed to put into JSONObject, make sure value is a primitive")
        }
        stringifiedValue = jsonObject.toString()
    }

    override fun stringify(): String {
        return stringifiedValue
    }
}

fun <K : String, V> hashMapFromJSON(jsonString: String, keyClass: Class<K>, valueClass: Class<V>): HashMap<K, V> {
    val json = JSONObject(jsonString)
    var result = HashMap<K, V>()
    json.keys().forEach {
        if (!keyClass.isInstance(it)) {
            throw IllegalArgumentException("Unexpected key type")
        }
        val value = json[it]
        if (!valueClass.isInstance(value)) {
            throw IllegalArgumentException("Unexpected value type")
        }
        result[it as K] = json[it] as V
    }
    return result
}

fun <V> arrayFromJSON(jsonString: String, valueClass: Class<V>): ArrayList<V> {
    val json = JSONArray(jsonString)
    var result = ArrayList<V>()
    for (i in 0 until json.length()) {
        val value = json[i]
        if (!valueClass.isInstance(value)) {
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

fun Integer.toJSONSerializable(): JSONSerializable {
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

fun parseJSON(json: String): Any? {
    val arr = JSONArray("[$json]")
    return arr.get(0)
}