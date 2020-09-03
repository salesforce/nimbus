//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.webview

import android.webkit.WebSettings
import android.webkit.WebView
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

/**
 * Unit tests for [WebViewBridge].
 */
class WebViewBridgeTest : StringSpec({

    lateinit var webViewBridge: WebViewBridge
    val mockWebSettings = mockk<WebSettings>(relaxed = true, relaxUnitFun = true) {
        every { javaScriptEnabled } returns false
    }
    val mockWebView = mockk<WebView>(relaxed = true) {
        every { settings } returns mockWebSettings
    }
    val mockPlugin1 = mockk<Plugin1>(relaxed = true)
    val mockPlugin1WebViewBinder = mockk<Plugin1WebViewBinder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin1
        every { getPluginName() } returns "Test"
    }
    val mockPlugin2 = mockk<Plugin2>(relaxed = true)
    val mockPlugin2WebViewBinder = mockk<Plugin2WebViewBinder>(relaxed = true) {
        every { getPlugin() } returns mockPlugin2
        every { getPluginName() } returns "Test2"
    }

    beforeTest {
        webViewBridge = mockWebView.bridge {
            bind(mockPlugin1WebViewBinder)
            bind(mockPlugin2WebViewBinder)
        }
    }

    "attach enables Javascript" {
        verify { mockWebSettings.javaScriptEnabled = true }
    }

    "attach adds NimbusBridge JavascriptInterface" {
        verify { mockWebView.addJavascriptInterface(webViewBridge, "_nimbus") }
    }

    "attach allows plugins to customize" {
        verify { mockPlugin1.customize(webViewBridge) }
        verify { mockPlugin2.customize(webViewBridge) }
    }

    "attach binds to binders" {
        verify { mockPlugin1WebViewBinder.bind(webViewBridge) }
        verify { mockPlugin2WebViewBinder.bind(webViewBridge) }
    }

    "attach adds binder JavascriptInterfaces" {
        verify { mockWebView.addJavascriptInterface(ofType(Plugin1WebViewBinder::class), eq("_Test")) }
        verify { mockWebView.addJavascriptInterface(ofType(Plugin2WebViewBinder::class), eq("_Test2")) }
    }

    "detachremoves NimbusBridge JavascriptInterface" {
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_nimbus") }
    }

    "detach cleans up plugins" {
        webViewBridge.detach()
        verify { mockPlugin1.cleanup(webViewBridge) }
        verify { mockPlugin2.cleanup(webViewBridge) }
    }

    "detach unbinds from binders" {
        webViewBridge.detach()
        verify { mockPlugin1WebViewBinder.unbind(webViewBridge) }
        verify { mockPlugin2WebViewBinder.unbind(webViewBridge) }
    }

    "detach removes binder JavascriptInterfaces" {
        webViewBridge.detach()
        verify { mockWebView.removeJavascriptInterface("_Test") }
        verify { mockWebView.removeJavascriptInterface("_Test2") }
    }

    "NativePluginNames returns JsonArray of string names" {
        val nativePluginNames = webViewBridge.nativePluginNames()
        nativePluginNames.shouldBe("[\"Test\",\"Test2\"]")
    }
})

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
