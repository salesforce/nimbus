package com.salesforce.nimbus.bridge.webview

import android.webkit.WebSettings
import android.webkit.WebView
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for [WebViewBridge].
 */
class WebViewBridgeTest {

    private lateinit var webViewBridge: WebViewBridge
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
        webViewBridge = WebViewBridge()
        webViewBridge.add(mockPlugin1Binder, mockPlugin2Binder)
    }

    @Test
    fun attachEnablesJavascript() {
        webViewBridge.attach(mockWebView)
        verify { mockWebSettings.javaScriptEnabled = true }
    }

    @Test
    fun attachAddsNimbusBridgeJavascriptInterface() {
        webViewBridge.attach(mockWebView)
        verify { mockWebView.addJavascriptInterface(webViewBridge, "_nimbus") }
    }

    @Test
    fun attachAllowsPluginsToCustomize() {
        webViewBridge.attach(mockWebView)
        verify { mockPlugin1.customize(webViewBridge) }
        verify { mockPlugin2.customize(webViewBridge) }
    }

    @Test
    fun attachBindsToBinders() {
        webViewBridge.attach(mockWebView)
        verify { mockPlugin1Binder.bind(webViewBridge) }
        verify { mockPlugin2Binder.bind(webViewBridge) }
    }

    @Test
    fun attachAddsBinderJavascriptInterfaces() {
        webViewBridge.attach(mockWebView)
        verify { mockWebView.addJavascriptInterface(ofType(Plugin1Binder::class), eq("_Test")) }
        verify { mockWebView.addJavascriptInterface(ofType(Plugin2Binder::class), eq("_Test2")) }
    }

    @Test
    fun detachRemovesNimbusBridgeJavascriptInterface() {
        webViewBridge.attach(mockWebView)
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_nimbus") }
    }

    @Test
    fun detachCleansUpPlugins() {
        webViewBridge.attach(mockWebView)
        webViewBridge.detach()
        verify { mockPlugin1.cleanup(webViewBridge) }
        verify { mockPlugin2.cleanup(webViewBridge) }
    }

    @Test
    fun detachUnbindsFromBinders() {
        webViewBridge.attach(mockWebView)
        webViewBridge.detach()
        verify { mockPlugin1Binder.unbind() }
        verify { mockPlugin2Binder.unbind() }
    }

    @Test
    fun detachRemovesBinderJavascriptInterfaces() {
        webViewBridge.attach(mockWebView)
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_Test") }
        verify { mockWebView.removeJavascriptInterface("_Test2") }
    }

    @Test
    fun makeCallbackReturnsCallbackWhenWebViewAttached() {
        webViewBridge.attach(mockWebView)
        val callback = webViewBridge.makeCallback("1")
        assertNotNull(callback)
        assertEquals(mockWebView, callback?.webView)
        assertEquals("1", callback?.callbackId)
    }

    @Test
    fun makeCallbackReturnsNullWhenWebViewNotAttached() {
        val callback = webViewBridge.makeCallback("1")
        assertNull(callback)
    }

    @Test
    fun nativePluginNamesReturnsJsonArrayStringOfNames() {
        webViewBridge.attach(mockWebView)
        val nativePluginNames = webViewBridge.nativePluginNames()
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
