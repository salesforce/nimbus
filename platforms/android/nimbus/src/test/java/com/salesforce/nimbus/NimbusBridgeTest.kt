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
  private val mockValidExtension = mockk<ValidExtension>(relaxed = true)
  private val mockValidExtension2 = mockk<ValidExtension2>(relaxed = true)
  private val mockInvalidExtension = mockk<InvalidExtension>(relaxed = true)

  @Before
  fun setUp() {
    bridge = NimbusBridge("http://localhost")
    bridge.addExtension(mockValidExtension)
    bridge.addExtension(mockValidExtension2)
    bridge.addExtension(mockInvalidExtension)
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
  fun attachAllowsValidExtensionsToCustomize() {
    bridge.attach(mockWebView)
    verify { mockValidExtension.customize(mockWebView) }
    verify { mockValidExtension2.customize(mockWebView) }
    verify(exactly = 0) { mockInvalidExtension.customize(mockWebView) }
  }

  @Test
  fun attachAddsBinderJavascriptInterfaces() {
    bridge.attach(mockWebView)
    verify { mockWebView.addJavascriptInterface(ofType(ValidExtensionBinder::class), eq("_Test")) }
    verify { mockWebView.addJavascriptInterface(ofType(ValidExtension2Binder::class), eq("_Test2")) }
  }

  @Test
  fun attachLoadsAppUrl() {
    bridge.attach(mockWebView)
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
    verify { mockValidExtension.cleanup(mockWebView) }
    verify { mockValidExtension2.cleanup(mockWebView) }
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

class InvalidExtension : NimbusExtension

@Extension(name = "Test")
class ValidExtension : NimbusExtension {

  @ExtensionMethod
  fun foo(): String {
    return "foo"
  }
}

@Extension(name = "Test2")
class ValidExtension2 : NimbusExtension {

  @ExtensionMethod
  fun foo(): String {
    return "foo"
  }
}
