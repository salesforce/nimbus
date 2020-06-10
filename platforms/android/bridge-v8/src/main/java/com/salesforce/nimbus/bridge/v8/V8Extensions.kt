package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.JavaCallback
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import com.eclipsesource.v8.utils.V8ObjectUtils
import com.salesforce.k2v8.toV8Array

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
fun V8.rejectPromise(error: String): V8Object {
    return promiseGlobal().executeObjectFunction(
        "reject",
        V8Array(this).push(error)
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
fun V8.bridge(builder: V8Bridge.Builder.() -> Unit = {}): V8Bridge {
    return V8Bridge.Builder().apply(builder).attach(this)
}

@Suppress("UNCHECKED_CAST")
fun V8Object.toMap(): Map<String, Any> = V8ObjectUtils.toMap(this) as Map<String, Any>

@Suppress("UNCHECKED_CAST")
fun V8Array.toList(): List<Any> = V8ObjectUtils.toList(this) as List<Any>

@Suppress("UNCHECKED_CAST")
fun V8Array.toArray(): Array<Any> = (V8ObjectUtils.toList(this) as List<Any>).toTypedArray()
