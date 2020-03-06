package com.salesforce.nimbusjs

import android.content.Context
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.nio.charset.StandardCharsets

class NimbusJSUtilities() {
    companion object Injection {
        fun injectedNimbusStream(inputStream: InputStream, context: Context): InputStream {
            val jsString = context.resources.openRawResource(R.raw.nimbus).bufferedReader(StandardCharsets.UTF_8).readText()
            var html = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
            val replacedHtml = html?.let {
                if (it.contains("<script>")) {
                    // If there exists a script tag on a page inject nimbus so it will be loaded first
                    html.replace("<script>", "<script>\n$jsString\n</script><script>")
                } else if (it.contains("<script ")) {
                    // If there exists a script tag on a page without a closing tag counterpart
                    html.replace("<script ", "<script>\n$jsString\n</script><script ")
                } else {
                    // If there is no script tag on a page then inject nimbus in one of head, body, or
                    // html tags.  If none of these tags exist then throw an exception.
                    if (it.contains("<head>")) {
                        html.replace("<head>", "<head><script>\n$jsString\n</script>")
                    } else if (it.contains("<body>")) {
                        html.replace("<body>", "<body><script>\n$jsString\n</script>")
                    } else if (it.contains("<html>")) {
                        html.replace("<html>", "<html><script>\n$jsString\n</script>")
                    } else {
                        throw Exception("Can't find any of <html>, <head>, or <body> to inject nimbus")
                    }
                }
            }

            return ByteArrayInputStream(replacedHtml.toByteArray(StandardCharsets.UTF_8))
        }
    }
}
