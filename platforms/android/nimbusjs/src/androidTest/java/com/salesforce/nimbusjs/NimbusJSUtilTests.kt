package com.salesforce.nimbusjs

import android.content.Context
import android.webkit.WebView
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import junit.framework.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.io.InputStream
import java.nio.charset.StandardCharsets
import java.util.concurrent.CountDownLatch


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
        var inputStream: InputStream = context.assets.open("testPage.html")
        inputStream = NimbusJSUtilities.injectedNimbusStream(inputStream, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        var containsNimbus = resultString?.contains("nimbus")
        assertEquals(true, containsNimbus)
        var containsScriptOpeningTag = resultString?.contains("<script>")
        assertEquals(true, containsScriptOpeningTag)
        var containsScriptClosingTag = resultString?.contains("</script>")
        assertEquals(true, containsScriptClosingTag)
    }
}
