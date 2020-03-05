package com.salesforce.nimbusjs

import android.content.Context
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import junit.framework.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.io.ByteArrayInputStream
import java.nio.charset.StandardCharsets


@RunWith(AndroidJUnit4::class)
class NimbusJSUtilsTests {

    lateinit var context: Context

    @Before
    fun setup() {
        context = InstrumentationRegistry.getInstrumentation().targetContext
    }

    @Test
    fun testInjectionHead() {
        val html = """
            <head>
                Here is the head of the document
            </head>
        """.trimIndent()
        val input = ByteArrayInputStream(html.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        var containsNimbus = resultString?.contains("nimbus")
        assertEquals(true, containsNimbus)
        var containsScriptOpeningTag = resultString?.contains("<script>")
        assertEquals(true, containsScriptOpeningTag)
        var containsScriptClosingTag = resultString?.contains("</script>")
        assertEquals(true, containsScriptClosingTag)
    }

    @Test
    fun testInjectionBody() {
        val html = """
            <body>
                Here is the body of the document
            </body>
        """.trimIndent()
        val input = ByteArrayInputStream(html.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        var containsNimbus = resultString?.contains("nimbus")
        assertEquals(true, containsNimbus)
        var containsScriptOpeningTag = resultString?.contains("<script>")
        assertEquals(true, containsScriptOpeningTag)
        var containsScriptClosingTag = resultString?.contains("</script>")
        assertEquals(true, containsScriptClosingTag)
    }

    @Test
    fun testInjectionHtml() {
        val html = """
            <html>
                Here is the html of the document
            </html>
        """.trimIndent()
        val input = ByteArrayInputStream(html.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        var containsNimbus = resultString?.contains("nimbus")
        assertEquals(true, containsNimbus)
        var containsScriptOpeningTag = resultString?.contains("<script>")
        assertEquals(true, containsScriptOpeningTag)
        var containsScriptClosingTag = resultString?.contains("</script>")
        assertEquals(true, containsScriptClosingTag)
    }

    @Test(expected = Exception::class)
    fun testInjectionFails() {
        val html = """
            <p>
                Here is the paragraph of the document
            <p>
        """.trimIndent()
        val input = ByteArrayInputStream(html.toByteArray(Charsets.UTF_8))
        NimbusJSUtilities.injectedNimbusStream(input, context)
    }
}
