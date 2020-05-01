package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.NIMBUS_BRIDGE
import com.salesforce.nimbus.NIMBUS_PLUGINS
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.runs
import io.mockk.slot
import io.mockk.verify
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for [V8Bridge].
 */
class V8BridgeTest {

    private lateinit var v8Bridge: V8Bridge
    private val mockV8 = mockk<V8>(relaxed = true)
    private val mockPlugin1 = mockk<Plugin1>(relaxed = true)
    private val mockPlugin1V8Binder = mockk<Plugin1V8Binder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin1
        every { getPluginName() } returns "Test"
    }
    private val mockPlugin2 = mockk<Plugin2>(relaxed = true)
    private val mockPlugin2V8Binder = mockk<Plugin2V8Binder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin2
        every { getPluginName() } returns "Test2"
    }

    @Before
    fun setUp() {
        mockkStatic("com.salesforce.nimbus.bridge.v8.V8ExtensionsKt")
        with(mockV8) {
            every { createObject() } returns mockk {
                every { add(any(), any<V8Object>()) } returns this
                every { registerVoidCallback(any(), any()) } returns this
                every { close() } just runs
            }
            every { add(any(), any<V8Object>()) } returns this
        }

        v8Bridge = V8Bridge()
        v8Bridge.add(mockPlugin1V8Binder, mockPlugin2V8Binder)
    }

    @Test
    fun attachAddsNimbusBridgeObject() {
        v8Bridge.attach(mockV8)
        slot<V8Object>().let {

            // verify bridge object is added
            verify { mockV8.add(NIMBUS_BRIDGE, capture(it)) }
            val nimbusBridge = it.captured

            // verify plugins object is added
            verify { nimbusBridge.add(NIMBUS_PLUGINS, any<V8Object>()) }
        }
    }

    @Test
    fun attachAddsInternalNimbusBridgeObject() {
        v8Bridge.attach(mockV8)
        slot<V8Object>().let {

            // verify internal bridge object is added
            verify { mockV8.add(INTERNAL_NIMBUS_BRIDGE, capture(it)) }
            val internalNimbusBridge = it.captured

            // verify callbacks are added
            verify { internalNimbusBridge.registerVoidCallback("resolvePromise", any()) }
            verify { internalNimbusBridge.registerVoidCallback("rejectPromise", any()) }
        }
    }

    @Test
    fun attachAllowsPluginsToCustomize() {
        v8Bridge.attach(mockV8)
        verify { mockPlugin1.customize(v8Bridge) }
        verify { mockPlugin2.customize(v8Bridge) }
    }

    @Test
    fun attachBindsToBinders() {
        v8Bridge.attach(mockV8)
        verify { mockPlugin1V8Binder.bind(v8Bridge) }
        verify { mockPlugin2V8Binder.bind(v8Bridge) }
    }

    @Test
    fun detachCleansUpPlugins() {
        v8Bridge.attach(mockV8)
        v8Bridge.detach()
        verify { mockPlugin1.cleanup(v8Bridge) }
        verify { mockPlugin2.cleanup(v8Bridge) }
    }

    @Test
    fun detachClosesObjects() {
        v8Bridge.attach(mockV8)

        // capture the nimbusBridge object
        val nimbusBridgeSlot = slot<V8Object>()
        verify { mockV8.add(NIMBUS_BRIDGE, capture(nimbusBridgeSlot)) }
        val nimbusBridge = nimbusBridgeSlot.captured

        // capture the nimbusPlugins object
        val nimbusPluginsSlot = slot<V8Object>()
        verify { nimbusBridge.add(NIMBUS_PLUGINS, capture(nimbusPluginsSlot)) }
        val nimbusPlugins = nimbusPluginsSlot.captured

        // capture the internalNimbusBridge object
        val internalNimbusBridgeSlot = slot<V8Object>()
        verify { mockV8.add(INTERNAL_NIMBUS_BRIDGE, capture(internalNimbusBridgeSlot)) }
        val internalNimbusBridge = internalNimbusBridgeSlot.captured

        v8Bridge.detach()
        verify { nimbusBridge.close() }
        verify { nimbusPlugins.close() }
        verify { internalNimbusBridge.close() }
    }
}

@PluginOptions(name = "Test")
class Plugin1 : Plugin {

    @BoundMethod
    fun foo(): String {
        return "foo"
    }
}

@PluginOptions(name = "Test2")
class Plugin2 : Plugin {

    @BoundMethod
    fun foo(): String {
        return "foo"
    }
}
