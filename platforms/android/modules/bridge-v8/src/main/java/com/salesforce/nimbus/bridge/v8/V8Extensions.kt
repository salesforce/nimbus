//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.*
import com.eclipsesource.v8.utils.MemoryManager
import com.salesforce.k2v8.toV8Array
import java.util.concurrent.ExecutorService

/**
 * Cleans up the [V8Object.registerJavaMethod] function a bit to move the method to first parameter.
 */
fun V8Object.registerJavaCallback(methodName: String, javaCallback: (V8Array) -> Any): V8Object =
    registerJavaMethod(JavaCallback { _, parameters -> javaCallback(parameters) }, methodName)

/**
 * Cleans up the [V8Object.registerJavaMethod] function a bit to move the method to first parameter.
 */
fun V8Object.registerVoidCallback(methodName: String, voidCallback: (V8Array) -> Unit): V8Object =
    registerJavaMethod({ _, parameters -> voidCallback(parameters) }, methodName)

/**
 * Returns the global Promise object.
 */
fun V8.promiseGlobal(): V8Object = getObject("Promise")

/**
 * Resolves a Promise with the [result].
 */
fun V8.resolvePromise(result: Any): V8Object {
    return promiseGlobal().executeObjectFunction(
        "resolve",
        this.convertAnyToV8Array(result)
    )
}

/**
 * Rejects a Promise with the [error].
 */
fun V8.rejectPromise(error: Any): V8Object {
    return promiseGlobal().executeObjectFunction(
        "reject",
        this.convertAnyToV8Array(error)
    )
}

/**
 * Convert any data to a V8Array for v8 function call
 * Will be empty array if data is Unit
 */
fun V8.convertAnyToV8Array(data: Any): V8Array {
    return if (data is List<*>) {
        data.toV8Array(this)
    } else {
        V8Array(this).apply {
            if (data != Unit) {
                push(data)
            }
        }
    }
}

/**
 * Helper function to create a [V8Object] which aids in testability.
 */
fun V8.createObject() = V8Object(this)

/**
 * Creates a [V8Bridge.Builder] and passes it to the [builder] function, allowing any binders to be added
 * and then attaches to the [V8Bridge] instance.
 */
fun V8.bridge(
    executorService: ExecutorService,
    builder: V8Bridge.Builder.() -> Unit = {}
): V8Bridge {
    return V8Bridge.Builder()
        .apply(builder)
        .attach(this, executorService)
}

/**
 * Creates a memory scope around the function [body].
 * After the [body] is invoked, any V8Value objects created in the body will be released
 * except the V8Value object is returned to caller for consumption.
 */
inline fun <T> V8.memoryScope(body: () -> T): T {
    val scope = MemoryManager(this)
    try {
        return body().apply {
            if (this is V8Value) {
                scope.persist(this)
            }
        }
    } finally {
        scope.release()
    }
}
