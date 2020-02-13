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
import java.io.*
import java.net.HttpURLConnection
import java.net.SocketTimeoutException
import java.net.URL
import java.nio.charset.StandardCharsets
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
    fun testInjectionTwo() {
        var inputStream: InputStream = context.assets.open("testPage.html")
        inputStream = NimbusJSUtilities.injectedNimbusStream(inputStream, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        var containsNimbus = resultString?.contains("nimbus")
        assertEquals(true, containsNimbus)
    }
}