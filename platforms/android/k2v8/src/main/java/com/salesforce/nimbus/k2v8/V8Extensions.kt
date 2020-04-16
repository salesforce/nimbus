package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
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
        forEach { push(it) }
    }
}

/**
 * Converts a [V8Array] from a [Map] typed [String, String].
 */
fun Map<String, String>.toV8Array(v8: V8): V8Array {
    return V8Array(v8).apply {
        entries.onEach { (key, value) -> add(key, value) }
    }
}
