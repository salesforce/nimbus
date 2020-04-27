package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.salesforce.nimbus.Binder
import com.salesforce.nimbus.Bridge
import com.salesforce.nimbus.JavascriptSerializable
import com.salesforce.nimbus.NIMBUS_BRIDGE
import com.salesforce.nimbus.NIMBUS_PLUGINS
import com.salesforce.nimbus.Runtime

class V8Bridge : Bridge<V8, V8Object>, Runtime<V8, V8Object> {

    private var bridgeV8: V8? = null
    private val binders = mutableListOf<Binder<V8, V8Object>>()
    private var nimbusBridge: V8Object? = null

    override fun add(vararg binder: Binder<V8, V8Object>) {
        binders.addAll(binder)
    }

    override fun attach(javascriptEngine: V8) {
        bridgeV8 = javascriptEngine

        // create the _nimbus bridge
        nimbusBridge = V8Object(javascriptEngine)
            .add(NIMBUS_PLUGINS, V8Object(javascriptEngine))

        // add to the bridge v8 engine
        javascriptEngine.add(NIMBUS_BRIDGE, nimbusBridge)

        // initialize plugins
        initialize(binders)
    }

    override fun detach() {
        bridgeV8?.let { v8 ->
            cleanup(binders)
            nimbusBridge?.close()
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
        // TODO handle
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
}
