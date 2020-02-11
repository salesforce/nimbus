package com.salesforce.nimbusjs

import android.content.Context
import android.util.Log
import android.webkit.*
import androidx.test.internal.runner.junit4.statement.UiThreadStatement.runOnUiThread
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import junit.framework.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.net.HttpURLConnection
import java.net.SocketTimeoutException
import java.net.URL
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit


@RunWith(AndroidJUnit4::class)
class NimbusJSUtilsTests {

    lateinit var context: Context
    lateinit var webView: WebView

    var readyLock = CountDownLatch(1)
    var lock = CountDownLatch(1)
    var receivedValue = ""

    @Before
    fun setup() {
        context = InstrumentationRegistry.getInstrumentation().targetContext
    }

    @Test
    fun testInjection() {
        runOnUiThread {
            webView = WebView(this.context)
            webView.settings.javaScriptEnabled = true
            webView.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    readyLock.countDown()
                }

                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    return true
                }

                override fun onLoadResource(view: WebView?, url: String?) {
                    super.onLoadResource(view, url)
                }

                override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse? {
                    try {
                        val method = request!!.method
                        val url = URL(request.url.toString())
                        val conn = url.openConnection() as HttpURLConnection
                        conn.requestMethod = method
                        conn.readTimeout = 30 * 1000
                        conn.connectTimeout = 30 * 1000
                        var responseHeaders: Map<String, String> = mapOf()
                        var responseStream = conn.inputStream
                        responseStream = NimbusJSUtilities.injectedNimbusStream(responseStream, context)
                        return WebResourceResponse("text/html", "utf-8", 200, "OK", responseHeaders, responseStream)
                    } catch (ex: SocketTimeoutException) {
                        println("blah")
                    } catch (ex: Exception) {
                        Log.e("blah", ex.toString())
                        println("blah")
                    }
                    return null
                }
            }
            webView.loadUrl("file:///android_asset/testPage.html")
        }

        readyLock.await(2000, TimeUnit.MILLISECONDS)

        runOnUiThread {
            val js = "window.nimbus !== undefined"
            webView.evaluateJavascript(js) { value ->
                receivedValue = value.toString()
                lock.countDown()
            }
        }
        lock.await(2000, TimeUnit.MILLISECONDS)
        assertEquals("true", receivedValue)
    }
}