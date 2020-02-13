package com.salesforce.nimbusjs

import android.content.Context
import android.util.Log
import android.webkit.WebView
import java.io.*
import java.nio.charset.StandardCharsets

class NimbusJSUtilities() {
    companion object Injection {
        fun injectedNimbusStream(inputStream: InputStream, context: Context): InputStream {
            val jsString = context.resources.openRawResource(R.raw.nimbus).bufferedReader(StandardCharsets.UTF_8).readText()
            var html = inputStream.bufferedReader(StandardCharsets.UTF_8).readText()
            if (html!!.contains("<head>")) {
                html = html.replace("<head>", "<head>\n$jsString\n")
            } else if (html.contains("</head>")) {
                html = html.replace("</head>", jsString + "\n" + "</head>")
            }
            return ByteArrayInputStream(html!!.toByteArray(StandardCharsets.UTF_8))
        }
    }
}
