//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import com.eclipsesource.v8.utils.V8ObjectUtils

/**
 * Wrapper [V8Encodable] class which wraps a primitive value in a [V8Array].
 */
class PrimitiveV8Encodable(v8: V8, private val value: Any) : V8Encodable {
    private val v8Object: V8Object = when (value) {
        is V8Object -> value

        // wrap primitive value in an array
        else -> V8Array(v8).apply { V8ObjectUtils.pushValue(v8, this, value) }
    }

    override fun encode(): V8Object {
        return v8Object
    }
}

fun String.toV8Encodable(v8: V8) = PrimitiveV8Encodable(v8, this)

fun Int.toV8Encodable(v8: V8) = PrimitiveV8Encodable(v8, this)

fun Long.toV8Encodable(v8: V8) = PrimitiveV8Encodable(v8, this)

fun Double.toV8Encodable(v8: V8): V8Encodable {
    return if (this == Double.NEGATIVE_INFINITY || this == Double.POSITIVE_INFINITY || this == Double.NaN as Number) {
        throw IllegalArgumentException("Double value should be finite.")
    } else PrimitiveV8Encodable(v8, this)
}

fun Boolean.toV8Encodable(v8: V8) = PrimitiveV8Encodable(v8, this)
