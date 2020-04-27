package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Value
import com.eclipsesource.v8.utils.MemoryManager

/**
 * Creates a scope around the function [body] releasing any objects after the [body] is invoked.
 */
inline fun <T> V8.scope(body: () -> T): T {
    val scope = MemoryManager(this)
    try {
        return body()
    } finally {
        scope.release()
    }
}

/**
 * Converts a [V8Array] from a [List] typed [T].
 */
fun <T> List<T>.toV8Array(v8: V8): V8Array {
    return V8Array(v8).apply {
        forEach { value ->
            when (value) {
                is List<*> -> push(value.toV8Array(v8))
                is Int,
                is Long,
                is Boolean,
                is Double,
                is Float,
                is String,
                is V8Value -> push(value)
                else -> throw IllegalArgumentException("The value type is not " +
                    "a supported type in a V8Array.")
            }
        }
    }
}

/**
 * Converts a [V8Array] from a [Map] typed [String, String].
 */
fun <V> Map<String, V>.toV8Array(v8: V8): V8Array {
    return V8Array(v8).apply {
        entries.onEach { (key, value) ->
            when (value) {
                is Int -> add(key, value as Int)
                is Long -> add(key, (value as Long).toInt())
                is Boolean -> add(key, value as Boolean)
                is Double -> add(key, value as Double)
                is Float -> add(key, (value as Float).toDouble())
                is String -> add(key, value as String)
                is V8Value -> add(key, value as V8Value)
                else -> throw IllegalArgumentException("The value type is not " +
                    "a supported Value type in a V8Array.")
            }
        }
    }
}
