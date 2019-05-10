//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import org.json.JSONObject

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
