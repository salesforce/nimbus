package com.salesforce.nimbus

/**
 * Defines an object which will be a runtime for a [JavascriptEngine].
 */
interface Runtime<JavascriptEngine> {

    /**
     * Get the [JavascriptEngine] powering the [Runtime].
     */
    fun getJavascriptEngine(): JavascriptEngine?

    /**
     * Invokes a [functionName] in the [JavascriptEngine].
     */
    fun invoke(
        functionName: String,
        args: Array<JSONSerializable?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)?
    )
}
