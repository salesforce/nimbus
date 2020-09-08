//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import com.eclipsesource.v8.utils.MemoryManager
import com.salesforce.k2v8.toV8Array
import com.salesforce.nimbus.Binder
import com.salesforce.nimbus.Bridge
import com.salesforce.nimbus.JSEncodable
import com.salesforce.nimbus.NIMBUS_BRIDGE
import com.salesforce.nimbus.NIMBUS_PLUGINS
import com.salesforce.nimbus.Runtime
import java.io.Closeable
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ExecutorService

const val INTERNAL_NIMBUS_BRIDGE = "_nimbus"

class V8Bridge(private val executorService: ExecutorService) : Bridge<V8, V8Object>, Runtime<V8, V8Object> {

    private var bridgeV8: V8? = null
    internal val binders = mutableListOf<Binder<V8, V8Object>>()
    private var nimbusBridge: V8Object? = null
    private var nimbusPlugins: V8Object? = null
    private var internalNimbusBridge: V8Object? = null
    private val promises: ConcurrentHashMap<String, (String?, Any?) -> Unit> = ConcurrentHashMap()

    override fun detach() {
        executorService.submit {
            cleanup(binders)
            nimbusBridge?.close()
            nimbusPlugins?.close()
            internalNimbusBridge?.close()
            bridgeV8?.close()
            bridgeV8 = null
        }.get()
    }

    override fun getJavascriptEngine(): V8? {
        return bridgeV8
    }

    /**
     * Return [ExecutorService] of the [Runtime]
     */
    override fun getExecutorService(): ExecutorService = executorService

    override fun invoke(
        functionName: String,
        args: Array<JSEncodable<V8Object>?>,
        callback: ((String?, Any?) -> Unit)?
    ) {
        executorService.submit {
            invokeInternal(functionName.split('.').toTypedArray(), args, callback)
        }.get()
    }

    private fun invokeInternal(
        identifierSegments: Array<String>,
        args: Array<JSEncodable<V8Object>?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)?
    ) {
        val v8 = bridgeV8 ?: return

        // encode parameters and add to v8
        val parameters = args.map {
            when (it) {
                is PrimitiveV8Encodable -> {
                    it.encode().let { encoded -> (encoded as V8Array?)?.get(0) ?: encoded }
                }
                else -> it?.encode()
            }
        }.toV8Array(v8)
        parameters.use { v8.add("parameters", it) }

        val promiseId = UUID.randomUUID().toString()
        callback?.let { promises[promiseId] = it }

        // convert function segments to a string array (eg., ["__nimbus", "func"]
        val idSegments = identifierSegments.toList().toString()

        // create our script to invoke the function and resolve the promise
        val script = """
                let idSegments = $idSegments;
                let promise = undefined;
                try {
                    let fn = idSegments.reduce((state, key) => {
                        return state[key];
                    });
                    promise = Promise.resolve(fn(...parameters));
                } catch (error) {
                    promise = Promise.reject(error);
                }
                promise.then((value) => {
                    _nimbus.resolvePromise("$promiseId", value);
                }).catch((err) => {
                    _nimbus.rejectPromise("$promiseId", err.toString());
                });
            """.trimIndent()

        // execute the script
        v8.executeScript(script)
    }

    private fun attachInternal(javascriptEngine: V8) {
        bridgeV8 = javascriptEngine

        // create the __nimbus bridge
        nimbusBridge = javascriptEngine.createObject()

            // add _nimbus.plugins
            .add(
                NIMBUS_PLUGINS,
                javascriptEngine.createObject().also { nimbusPlugins = it }
            )

        // add to the bridge v8 engine
        javascriptEngine.add(NIMBUS_BRIDGE, nimbusBridge)

        // create an internal nimbus to resolve promises
        internalNimbusBridge = javascriptEngine.createObject()
            .registerVoidCallback("resolvePromise") { parameters ->
                val result = parameters.get(1)
                promises.remove(parameters.getString(0))?.invoke(null, result)
                (result as Closeable?)?.close()
            }
            .registerVoidCallback("rejectPromise") { parameters ->
                promises.remove(parameters.getString(0))?.invoke(parameters.getString(1), null)
            }

        // add the internal bridge to the v8 engine
        javascriptEngine.add(INTERNAL_NIMBUS_BRIDGE, internalNimbusBridge)

        // initialize plugins
        initialize(binders)
    }

    private fun initialize(binders: Collection<Binder<V8, V8Object>>) {
        binders.forEach { binder ->

            // customize if needed
            binder.getPlugin().customize(this)

            // bind plugin
            binder.bind(this)
        }
    }

    private fun cleanup(binders: Collection<Binder<V8, V8Object>>) {
        binders.forEach { binder ->

            // cleanup if needed
            binder.getPlugin().cleanup(this)

            // unbind plugin
            binder.unbind(this)
        }
    }

    protected fun finalize() {
        promises.values.forEach { it.invoke("Canceled", null) }
        promises.clear()
    }

    /**
     * Builder class to create instances of [V8Bridge] and attach to a [V8] runtime.
     */
    class Builder : Bridge.Builder<V8, V8Object, V8Bridge>() {
        override fun attach(javascriptEngine: V8, executorService: ExecutorService): V8Bridge {
            return V8Bridge(executorService).apply {
                binders.addAll(builderBinders)
                executorService.submit {
                    attachInternal(javascriptEngine)
                }.get()
            }
        }
    }

    fun <T> executorScope(executorService: ExecutorService, body: () -> T): T {
        val scope = executorService.submit<MemoryManager> { MemoryManager(bridgeV8) }.get()
        try {
            return body()
        } finally {
            executorService.submit { scope.release() }.get()
        }
    }

    fun executeScriptOnExecutor(script: String) {
        bridgeV8?.let { executorService.submit { it.executeScript(script) }.get() }
    }
}
