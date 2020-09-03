//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.JavaCallback
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
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
        if (result is List<*>) {
            result.toV8Array(this)
        } else {
            V8Array(this).push(result)
        }
    )
}

/**
 * Rejects a Promise with the [error].
 */
fun V8.rejectPromise(error: Any): V8Object {
    return promiseGlobal().executeObjectFunction(
        "reject",
        if (error is List<*>) {
            error.toV8Array(this)
        } else {
            V8Array(this).push(error)
        }
    )
}

/**
 * Helper function to create a [V8Object] which aids in testability.
 */
fun V8.createObject() = V8Object(this)

/**
 * Creates a [V8Bridge.Builder] and passes it to the [builder] function, allowing any binders to be added
 * and then attaches to the [V8Bridge] instance.
 */
fun V8.bridge(executorService: ExecutorService, builder: V8Bridge.Builder.() -> Unit = {}): V8Bridge {
    return V8Bridge.Builder()
        .apply(builder)
        .attach(executorService, this)
}
