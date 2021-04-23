//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.*

/**
 * a kotlin Promise wrapped around js Promise to simplify promise interaction in js.
 */
class Promise private constructor(
    private val _jsPromise: V8Object,
    private val _resolve: V8Function? = null,
    private val _reject: V8Function? = null
) {

    private val v8: V8 = _jsPromise.runtime

    fun getJsPromise() = _jsPromise

    /**
     * resolve the promise with result
     *
     * @param result the data to resolve to
     */
    fun resolve(result: Any) {
        if (_resolve == null) {
            throw UnsupportedOperationException("v8 directly returned promise doesn't support resolve.")
        }

        try {
            v8.convertAnyToV8Array(result).use {
                _resolve.call(v8, it)
            }
        } catch (exception: Exception) {
            throw exception
        } finally {
            releaseFunctions()
        }
    }

    /**
     * reject the promise with error
     */
    fun reject(error: Any) {
        if (_reject == null) {
            throw UnsupportedOperationException("v8 directly returned promise doesn't support reject.")
        }

        try {
            v8.convertAnyToV8Array(error).use {
                _reject.call(v8, it)
            }
        } catch (exception: Exception) {
            throw exception
        } finally {
            releaseFunctions()
        }
    }

    /**
     * like js promise then, either onFulfilled is called when promise resolved
     * or onRejected is called when the promise is rejected
     *
     * !!! not like js promise, here we don't support the chain of then as a new promise, not needed for now.
     */
    fun then(onFulfilled: (String) -> Unit, onRejected: (String) -> Unit) {
        val onResolvedFun = V8Function(v8) { _, params ->
            val data = getV8ArrayItemAsString(params, 0)
            onFulfilled(data)
            true
        }

        val onRejectedFun = V8Function(v8) { _, params ->
            val reason = getV8ArrayItemAsString(params, 0)
            onRejected(reason)
            true
        }

        onResolvedFun.use {
            onRejectedFun.use {
                val newJsPromise =
                    _jsPromise.executeJSFunction("then", onResolvedFun, onRejectedFun) as V8Object
                newJsPromise.close()
            }
        }
    }

    /**
     * release the js promise and resolve, reject v8 function if haven't done so.
     */
    fun close() {
        if (!_jsPromise.isReleased) _jsPromise.close()
        releaseFunctions()
    }

    /**
     * release the resolve, reject v8 function if haven't done so
     */
    private fun releaseFunctions() {
        if (_resolve != null && !_resolve.isReleased) _resolve.close()
        if (_reject != null && !_reject.isReleased) _reject.close()
    }

    /**
     * get an item in V8Array as string at the spot of index
     * @param params V8Array
     * @param index Int
     * @return String
     */
    private fun getV8ArrayItemAsString(params: V8Array, index: Int): String {
        return when (params.getType(index)) {
            V8Value.V8_OBJECT -> convertV8ObjectToJsonString(params.getObject(index))
            else -> params.get(index).toString()
        }
    }

    private fun convertV8ObjectToJsonString(v8Object: V8Object): String {
        return v8.getObject("JSON").use { json ->
            V8Array(v8).push(v8Object).use { parameters ->
                json.executeStringFunction("stringify", parameters)
            }
        }
    }

    companion object {

        /**
         * create an instance of Promise on specified v8 with status pending
         * !!! Call close method to release reference otherwise leaks
         *
         * @param v8 the V8 instance where the promise is created.
         */
        fun newPromise(v8: V8): Promise =
            v8.executeObjectScript(
                """(() => {
                var resolveRef;
                var rejectRef;
                var p = new Promise(
                    (resolve, reject) => {
                        resolveRef = resolve;
                        rejectRef = reject;
                    }
                );
                return {
                    promise: p,
                    resolve: resolveRef,
                    reject: rejectRef
                }
            })()""".trimIndent()
            ).use {
                return Promise(
                    it.getObject("promise"),
                    it.getObject("resolve") as V8Function,
                    it.getObject("reject") as V8Function
                )
            }

        /**
         * wrap a js promise as [Promise] so to simplify the .then call
         * resolve or reject from kotlin side is not supported
         *
         * @param jsPromise the js promise v8 object
         */
        fun from(jsPromise: V8Object): Promise {
            jsPromise.getObject("then").use {
                if (it.v8Type == V8Object.UNDEFINED) {
                    throw UnsupportedOperationException("the jsPromise paramter passed is not a javascript promise v8 object")
                }
                return Promise(jsPromise)
            }
        }
    }
}
