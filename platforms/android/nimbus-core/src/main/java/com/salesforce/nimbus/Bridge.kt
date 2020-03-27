package com.salesforce.nimbus

/**
 * Defines an object which will be a bridge between a native [Plugin] and a [JavascriptEngine],
 * such as an Android WebView or V8.
 */
interface Bridge<JavascriptEngine> {

    /**
     * Adds a plugin [Binder] to the [Bridge].
     */
    fun add(vararg binder: Binder<JavascriptEngine>)

    /**
     * Attaches the [Bridge] to a [JavascriptEngine].
     */
    fun attach(javascriptEngine: JavascriptEngine)

    /**
     * Detaches the [Bridge] from a [JavascriptEngine].
     */
    fun detach()
}
