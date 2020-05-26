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
    private val mockPlugin1WebViewBinder = mockk<Plugin1WebViewBinder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin1
        every { getPluginName() } returns "Test"
    }
    private val mockPlugin2 = mockk<Plugin2>(relaxed = true)
    private val mockPlugin2WebViewBinder = mockk<Plugin2WebViewBinder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin2
        every { getPluginName() } returns "Test2"
    }

    @Before
    fun setUp() {
        webViewBridge = WebViewBridge.Builder()
            .bind(mockPlugin1WebViewBinder)
            .bind(mockPlugin2WebViewBinder)
            .attach(mockWebView)
    }

    @Test
    fun attachEnablesJavascript() {
        verify { mockWebSettings.javaScriptEnabled = true }
    }

    @Test
    fun attachAddsNimbusBridgeJavascriptInterface() {
        verify { mockWebView.addJavascriptInterface(webViewBridge, "_nimbus") }
    }

    @Test
    fun attachAllowsPluginsToCustomize() {
        verify { mockPlugin1.customize(webViewBridge) }
        verify { mockPlugin2.customize(webViewBridge) }
    }

    @Test
    fun attachBindsToBinders() {
        verify { mockPlugin1WebViewBinder.bind(webViewBridge) }
        verify { mockPlugin2WebViewBinder.bind(webViewBridge) }
    }

    @Test
    fun attachAddsBinderJavascriptInterfaces() {
        verify { mockWebView.addJavascriptInterface(ofType(Plugin1WebViewBinder::class), eq("_Test")) }
        verify { mockWebView.addJavascriptInterface(ofType(Plugin2WebViewBinder::class), eq("_Test2")) }
    }

    @Test
    fun detachRemovesNimbusBridgeJavascriptInterface() {
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_nimbus") }
    }

    @Test
    fun detachCleansUpPlugins() {
        webViewBridge.detach()
        verify { mockPlugin1.cleanup(webViewBridge) }
        verify { mockPlugin2.cleanup(webViewBridge) }
    }

    @Test
    fun detachUnbindsFromBinders() {
        webViewBridge.detach()
        verify { mockPlugin1WebViewBinder.unbind(webViewBridge) }
        verify { mockPlugin2WebViewBinder.unbind(webViewBridge) }
    }

    @Test
    fun detachRemovesBinderJavascriptInterfaces() {
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_Test") }
        verify { mockWebView.removeJavascriptInterface("_Test2") }
    }

    @Test
    fun makeCallbackReturnsCallbackWhenWebViewAttached() {
        val callback = webViewBridge.makeCallback("1")
        assertNotNull(callback)
        assertEquals(mockWebView, callback?.webView)
        assertEquals("1", callback?.callbackId)
    }

    @Test
    fun makeCallbackReturnsNullWhenWebViewNotAttached() {
        webViewBridge.detach()
        val callback = webViewBridge.makeCallback("1")
        assertNull(callback)
    }

    @Test
    fun nativePluginNamesReturnsJsonArrayStringOfNames() {
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
