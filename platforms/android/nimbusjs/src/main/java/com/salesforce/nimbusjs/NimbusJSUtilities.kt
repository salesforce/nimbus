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
            if (html!!.contains("<head>")) {
                html = html.replace("<head>", "<head>\n<script>\n$jsString\n</script>")
            } else if (html.contains("</head>")) {
                html = html.replace("</head>", "<script>\n$jsString\n</script>\n</head>")
            }
            return ByteArrayInputStream(html!!.toByteArray(StandardCharsets.UTF_8))
        }
    }
}
