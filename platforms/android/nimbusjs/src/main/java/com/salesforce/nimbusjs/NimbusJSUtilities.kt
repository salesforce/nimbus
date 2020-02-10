package com.salesforce.nimbusjs

import android.content.Context
import android.webkit.WebView
import java.io.BufferedReader

class NimbusJSUtilities() {
    companion object Injection {
        fun injectNimbus(webView: WebView, context: Context) {
            try {
                val inputStream = context.assets.open("raw/nimbus.js")
                inputStream.bufferedReader().use(BufferedReader::readText)
            } catch (e: Exception) {
                null
            }?.let { webView.loadUrl("javascript:($it)()")  }
        }
    }
}