package com.salesforce.nimbus

import android.webkit.WebView
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.salesforce.k2v8.Configuration
import com.salesforce.k2v8.K2V8
import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonConfiguration

/**
 * Defines an object which will be a runtime for a [JavascriptEngine] with a [EncodedType]
 * representing the encoded type that the [JavascriptEngine] expects.
 */
interface Runtime<JavascriptEngine, EncodedType> {

    /**
     * Get the [JavascriptEngine] powering the [Runtime].
     */
    fun getJavascriptEngine(): JavascriptEngine?

    /**
     * Invokes a [functionName] in the [JavascriptEngine].
     */
    fun invoke(
        functionName: String,
        args: Array<JSEncodable<EncodedType>?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)?
    )
}

/**
 * Calls [Runtime.invoke] and decodes the return value with the provided [kSerializer].
 */
inline fun <DecodedType : Any, JavascriptEngine, reified EncodedType> Runtime<JavascriptEngine, EncodedType>.invoke(
    functionName: String,
    args: Array<JSEncodable<EncodedType>?>,
    kSerializer: KSerializer<DecodedType>,
    crossinline callback: (String?, DecodedType?) -> Unit
) {
    invoke(functionName, args) { error, result ->
        if (error != null) {
            callback(error, null)
        } else if (result != null) {
            @Suppress("UNCHECKED_CAST")
            when (result) {
                is EncodedType -> {
                    when (val engine = getJavascriptEngine()) {
                        is V8 -> {
                            callback(
                                null,
                                K2V8(Configuration(engine as V8)).fromV8(
                                    kSerializer,
                                    result as V8Object
                                )
                            )
                        }
                        is WebView -> {
                            callback(
                                null,
                                Json(JsonConfiguration.Stable).parse(kSerializer, result as String)
                            )
                        }
                    }
                }
                else -> callback(null, result as DecodedType?)
            }
        }
    }
}
