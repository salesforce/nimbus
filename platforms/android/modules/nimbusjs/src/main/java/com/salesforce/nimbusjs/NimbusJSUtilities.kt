package com.salesforce.nimbusjs

import android.content.Context
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.nio.charset.StandardCharsets

class NimbusJSUtilities {
    companion object Injection {
        fun injectedNimbusStream(inputStream: InputStream, context: Context): InputStream {
            val jsString = context.resources.openRawResource(R.raw.nimbus).bufferedReader(StandardCharsets.UTF_8).readText()
            val html = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()

            // Inject nimbus script into head or html tag.
            // If none of these tags exist then throw an exception.
            listOf("<head>", "<html>").forEach {
                if (html.contains(it)) {
                    return ByteArrayInputStream(
                        html.replace(it, "$it<script>\n$jsString\n</script>")
                            .toByteArray(StandardCharsets.UTF_8))
                }
            }
            throw Exception("Can't find any of <html> or <head> to inject nimbus")
        }
    }
}
