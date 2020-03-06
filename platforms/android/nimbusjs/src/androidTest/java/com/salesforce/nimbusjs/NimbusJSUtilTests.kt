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
    lateinit var nimbusJsStringWithScriptTags: String

    @Before
    fun setup() {
        context = InstrumentationRegistry.getInstrumentation().targetContext
        val nimbusJsString = context.resources.openRawResource(R.raw.nimbus).bufferedReader(StandardCharsets.UTF_8).readText()
        nimbusJsStringWithScriptTags = "<script>\n$nimbusJsString\n</script>"
    }

    @Test
    fun testInjectionScript() {
        val html = """
            <html>
            <head>
                Here is the head of the document
                <inject><script>console.log('test');</script>
            </head>
            <body>
                And here is the body
            </body>
            </html>
        """.trimIndent()
        val htmlWithEmptyString = html.replace("<inject>", "")
        val input = ByteArrayInputStream(htmlWithEmptyString.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        val htmlWithNimbus = html.replace("<inject>", nimbusJsStringWithScriptTags)
        assertEquals(true, resultString.equals(htmlWithNimbus))
    }

    @Test
    fun testInjectionScriptWithoutClosingTag() {
        val html = """
            <html>
            <head>
                Here is the head of the document
                <inject><script src="test.js"/>
            </head>
            <body>
                And here is the body
            </body>
            </html>
        """.trimIndent()
        val htmlWithEmptyString = html.replace("<inject>", "")
        val input = ByteArrayInputStream(htmlWithEmptyString.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        val htmlWithNimbus = html.replace("<inject>", nimbusJsStringWithScriptTags)
        assertEquals(true, resultString.equals(htmlWithNimbus))
    }

    @Test
    fun testInjectionHead() {
        val html = """
            <head><inject>
                Here is the head of the document
            </head>
        """.trimIndent()
        val htmlWithEmptyString = html.replace("<inject>", "")
        val input = ByteArrayInputStream(htmlWithEmptyString.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        var resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        val htmlWithNimbus = html.replace("<inject>", nimbusJsStringWithScriptTags)
        assertEquals(true, resultString.equals(htmlWithNimbus))
    }

    @Test
    fun testInjectionBody() {
        val html = """
            <body><inject>
                Here is the body of the document
            </body>
        """.trimIndent()
        val htmlWithEmptyString = html.replace("<inject>", "")
        val input = ByteArrayInputStream(htmlWithEmptyString.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        val resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        val htmlWithNimbus = html.replace("<inject>", nimbusJsStringWithScriptTags)
        assertEquals(true, resultString.equals(htmlWithNimbus))
    }

    @Test
    fun testInjectionHtml() {
        val html = """
            <html><inject>
                Here is the html of the document
            </html>
        """.trimIndent()
        val htmlWithEmptyString = html.replace("<inject>", "")
        val input = ByteArrayInputStream(htmlWithEmptyString.toByteArray(Charsets.UTF_8))
        val inputStream = NimbusJSUtilities.injectedNimbusStream(input, context)
        val resultString = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
        val htmlWithNimbus = html.replace("<inject>", nimbusJsStringWithScriptTags)
        assertEquals(true, resultString.equals(htmlWithNimbus))
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
