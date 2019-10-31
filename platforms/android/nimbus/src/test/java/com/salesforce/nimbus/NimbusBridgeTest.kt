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

  private lateinit var bridge: NimbusBridge
  private val mockWebSettings = mockk<WebSettings>(relaxed = true, relaxUnitFun = true) {
    every { javaScriptEnabled } returns false
  }
  private val mockWebView = mockk<WebView>(relaxed = true) {
    every { settings } returns mockWebSettings
  }
  private val mockExtension1 = mockk<Extension1>(relaxed = true)
  private val mockExtension1Binder = mockk<Extension1Binder>(relaxed = true) {
    every { getExtension() } returns mockExtension1
    every { getExtensionName() } returns "Test"
  }
  private val mockExtension2 = mockk<Extension2>(relaxed = true)
  private val mockExtension2Binder = mockk<Extension2Binder>(relaxed = true) {
    every { getExtension() } returns mockExtension2
    every { getExtensionName() } returns "Test2"
  }

  @Before
  fun setUp() {
    bridge = NimbusBridge()
    bridge.add(mockExtension1Binder, mockExtension2Binder)
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
  fun attachAllowsExtensionsToCustomize() {
    bridge.attach(mockWebView)
    verify { mockExtension1.customize(mockWebView) }
    verify { mockExtension2.customize(mockWebView) }
  }

  @Test
  fun attachSetsWebViewOnBinders() {
    bridge.attach(mockWebView)
    verify { mockExtension1Binder.setWebView(mockWebView) }
    verify { mockExtension2Binder.setWebView(mockWebView) }
  }

  @Test
  fun attachAddsBinderJavascriptInterfaces() {
    bridge.attach(mockWebView)
    verify { mockWebView.addJavascriptInterface(ofType(Extension1Binder::class), eq("_Test")) }
    verify { mockWebView.addJavascriptInterface(ofType(Extension2Binder::class), eq("_Test2")) }
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
  fun detachCleansUpExtensions() {
    bridge.attach(mockWebView)
    bridge.detach()
    verify { mockExtension1.cleanup(mockWebView) }
    verify { mockExtension2.cleanup(mockWebView) }
  }

  @Test
  fun detachSetsWebViewToNullOnBinders() {
    bridge.attach(mockWebView)
    bridge.detach()
    verify { mockExtension1Binder.setWebView(null) }
    verify { mockExtension2Binder.setWebView(null) }
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
  fun nativeExtensionNamesReturnsJsonArrayStringOfNames() {
    bridge.attach(mockWebView)
    val nativeExtensionNames = bridge.nativeExtensionNames()
    assertEquals("[\"Test\",\"Test2\"]", nativeExtensionNames)
  }
}

@Extension(name = "Test")
class Extension1 : NimbusExtension {

  @ExtensionMethod
  fun foo(): String {
    return "foo"
  }
}

@Extension(name = "Test2")
class Extension2 : NimbusExtension {

  @ExtensionMethod
  fun foo(): String {
    return "foo"
  }
}
