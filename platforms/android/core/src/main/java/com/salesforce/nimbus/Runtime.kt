package com.salesforce.nimbus

/**
 * Defines an object which will be a runtime for a [JavascriptEngine] with a [SerializedOutputType]
 * representing the serialized type that the [JavascriptEngine] expects.
 */
interface Runtime<JavascriptEngine, SerializedOutputType> {

    /**
     * Get the [JavascriptEngine] powering the [Runtime].
     */
    fun getJavascriptEngine(): JavascriptEngine?

    /**
     * Invokes a [functionName] in the [JavascriptEngine].
     */
    fun invoke(
        functionName: String,
        args: Array<JavascriptSerializable<SerializedOutputType>?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)?
    )
}
