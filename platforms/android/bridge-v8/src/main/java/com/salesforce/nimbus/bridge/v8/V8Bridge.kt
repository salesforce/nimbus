package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.salesforce.nimbus.Binder
import com.salesforce.nimbus.Bridge
import com.salesforce.nimbus.JavascriptSerializable
import com.salesforce.nimbus.NIMBUS_BRIDGE
import com.salesforce.nimbus.NIMBUS_PLUGINS
import com.salesforce.nimbus.Runtime
import com.salesforce.nimbus.k2v8.toV8Array
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

const val INTERNAL_NIMBUS_BRIDGE = "_nimbus"

class V8Bridge : Bridge<V8, V8Object>, Runtime<V8, V8Object> {

    var bridgeV8: V8? = null
        private set
    private val binders = mutableListOf<Binder<V8, V8Object>>()
    private var nimbusBridge: V8Object? = null
    private var internalNimbusBridge: V8Object? = null
    private val promises: ConcurrentHashMap<String, (String?, Any?) -> Unit> = ConcurrentHashMap()

    override fun add(vararg binder: Binder<V8, V8Object>) {
        binders.addAll(binder)
    }

    override fun attach(javascriptEngine: V8) {
        bridgeV8 = javascriptEngine

        // create the __nimbus bridge
        nimbusBridge = V8Object(javascriptEngine)

            // add _nimbus.plugins
            .add(NIMBUS_PLUGINS, V8Object(javascriptEngine))

        // add to the bridge v8 engine
        javascriptEngine.add(NIMBUS_BRIDGE, nimbusBridge)

        // create an internal nimbus to resolve promises
        internalNimbusBridge = V8Object(javascriptEngine)
            .registerVoidCallback("resolvePromise") { parameters ->
                promises.remove(parameters.getString(0))?.invoke(null, parameters.get(1))
            }
            .registerVoidCallback("rejectPromise") { parameters ->
                promises.remove(parameters.getString(0))?.invoke(parameters.getString(1), null)
            }

        // add the internal bridge to the v8 engine
        javascriptEngine.add(INTERNAL_NIMBUS_BRIDGE, internalNimbusBridge)


        // initialize plugins
        initialize(binders)
    }

    override fun detach() {
        bridgeV8?.let { v8 ->
            cleanup(binders)
            nimbusBridge?.close()
            internalNimbusBridge?.close()
            v8.close()
            bridgeV8 = null
        }
    }

    override fun getJavascriptEngine(): V8? {
        return bridgeV8
    }

    override fun invoke(
        functionName: String,
        args: Array<JavascriptSerializable<V8Object>?>,
        callback: ((String?, Any?) -> Unit)?
    ) {
        invokeInternal(functionName.split('.').toTypedArray(), args, callback)
    }

    private fun invokeInternal(
        identifierSegments: Array<String>,
        args: Array<JavascriptSerializable<V8Object>?> = emptyArray(),
        callback: ((String?, Any?) -> Unit)?
    ) {
        val v8 = bridgeV8 ?: return

        // encode parameters and add to v8
        v8.add("parameters", args.mapNotNull { it?.serialize() }.toV8Array(v8))

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
}
