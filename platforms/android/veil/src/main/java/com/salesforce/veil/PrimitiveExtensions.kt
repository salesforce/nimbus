package com.salesforce.veil

import org.json.JSONObject


// Making this internal so it's not a footgun to consumers
internal class PrimitiveJSONSerializable(val value: Any) : JSONSerializable {
    val stringifiedValue: String

    init {
        val jsonObject = JSONObject()
        jsonObject.put("", value)
        if (jsonObject.get("") == null) {
            throw IllegalArgumentException("Failed to put into JSONObject, make sure value is a primitive");
        }
        stringifiedValue = jsonObject.toString()
    }

    override fun stringify(): String {
        return stringifiedValue
    }
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
    return PrimitiveJSONSerializable(this)
}