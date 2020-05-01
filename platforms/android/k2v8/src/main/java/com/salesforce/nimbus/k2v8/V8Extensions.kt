package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import com.eclipsesource.v8.utils.MemoryManager
import com.eclipsesource.v8.utils.V8ObjectUtils

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
    return V8ObjectUtils.toV8Array(v8, this)
}

/**
 * Converts a [V8Array] from a [Map] typed [String, String].
 */
fun <V> Map<String, V>.toV8Object(v8: V8): V8Object {
    return V8ObjectUtils.toV8Object(v8, this)
}
