package com.salesforce.nimbus

/**
 * Defines an object which will be a bridge between a native [Plugin] and a [JavascriptEngine],
 * such as an Android WebView or V8. [EncodedType] represents the encoded type the
 * [JavascriptEngine] expects.
 */
interface Bridge<JavascriptEngine, EncodedType> {

    /**
     * Adds a plugin [Binder] to the [Bridge].
     */
    fun add(vararg binder: Binder<JavascriptEngine, EncodedType>)

    /**
     * Attaches the [Bridge] to a [JavascriptEngine].
     */
    fun attach(javascriptEngine: JavascriptEngine)

    /**
     * Detaches the [Bridge] from a [JavascriptEngine].
     */
    fun detach()
}
