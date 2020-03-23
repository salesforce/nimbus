package com.salesforce.nimbus

import android.webkit.WebSettings
import android.webkit.WebView
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for [NimbusBridge].
 */
class NimbusBridgeTest {

    private lateinit var bridge: Bridge
    private val mockWebSettings = mockk<WebSettings>(relaxed = true, relaxUnitFun = true) {
        every { javaScriptEnabled } returns false
    }
    private val mockWebView = mockk<WebView>(relaxed = true) {
        every { settings } returns mockWebSettings
    }
    private val mockPlugin1 = mockk<Plugin1>(relaxed = true)
    private val mockPlugin1Binder = mockk<Plugin1Binder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin1
        every { getPluginName() } returns "Test"
    }
    private val mockPlugin2 = mockk<Plugin2>(relaxed = true)
    private val mockPlugin2Binder = mockk<Plugin2Binder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin2
        every { getPluginName() } returns "Test2"
    }

    @Before
    fun setUp() {
        bridge = Bridge()
        bridge.add(mockPlugin1Binder, mockPlugin2Binder)
    }

    @Test
    fun attachEnablesJavascript() {
        bridge.attach(mockWebView)
        verify { mockWebSettings.javaScriptEnabled = true }
    }

    @Test
    fun attachAddsNimbusBridgeJavascriptInterface() {
        bridge.attach(mockWebView)
        verify { mockWebView.addJavascriptInterface(bridge, "_nimbus") }
    }

    @Test
    fun attachAllowsPluginsToCustomize() {
        bridge.attach(mockWebView)
        verify { mockPlugin1.customize(mockWebView, bridge) }
        verify { mockPlugin2.customize(mockWebView, bridge) }
    }

    @Test
    fun attachSetsWebViewOnBinders() {
        bridge.attach(mockWebView)
        verify { mockPlugin1Binder.setWebView(mockWebView) }
        verify { mockPlugin2Binder.setWebView(mockWebView) }
    }

    @Test
    fun attachAddsBinderJavascriptInterfaces() {
        bridge.attach(mockWebView)
        verify { mockWebView.addJavascriptInterface(ofType(Plugin1Binder::class), eq("_Test")) }
        verify { mockWebView.addJavascriptInterface(ofType(Plugin2Binder::class), eq("_Test2")) }
    }

    @Test
    fun attachLoadsAppUrl() {
        bridge.attach(mockWebView)
        bridge.loadUrl("http://localhost")
        verify { mockWebView.loadUrl("http://localhost") }
    }

    @Test
    fun detachRemovesNimbusBridgeJavascriptInterface() {
        bridge.attach(mockWebView)
        bridge.detach()
        verify { mockWebView.removeJavascriptInterface("_nimbus") }
    }

    @Test
    fun detachCleansUpPlugins() {
        bridge.attach(mockWebView)
        bridge.detach()
        verify { mockPlugin1.cleanup(mockWebView, bridge) }
        verify { mockPlugin2.cleanup(mockWebView, bridge) }
    }

    @Test
    fun detachSetsWebViewToNullOnBinders() {
        bridge.attach(mockWebView)
        bridge.detach()
        verify { mockPlugin1Binder.setWebView(null) }
        verify { mockPlugin2Binder.setWebView(null) }
    }

    @Test
    fun detachRemovesBinderJavascriptInterfaces() {
        bridge.attach(mockWebView)
        bridge.detach()
        verify { mockWebView.removeJavascriptInterface("_Test") }
        verify { mockWebView.removeJavascriptInterface("_Test2") }
    }

    @Test
    fun makeCallbackReturnsCallbackWhenWebViewAttached() {
        bridge.attach(mockWebView)
        val callback = bridge.makeCallback("1")
        assertNotNull(callback)
        assertEquals(mockWebView, callback?.webView)
        assertEquals("1", callback?.callbackId)
    }

    @Test
    fun makeCallbackReturnsNullWhenWebViewNotAttached() {
        val callback = bridge.makeCallback("1")
        assertNull(callback)
    }

    @Test
    fun nativePluginNamesReturnsJsonArrayStringOfNames() {
        bridge.attach(mockWebView)
        val nativePluginNames = bridge.nativePluginNames()
        assertEquals("[\"Test\",\"Test2\"]", nativePluginNames)
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
