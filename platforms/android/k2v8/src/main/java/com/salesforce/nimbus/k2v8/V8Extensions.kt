package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8
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
