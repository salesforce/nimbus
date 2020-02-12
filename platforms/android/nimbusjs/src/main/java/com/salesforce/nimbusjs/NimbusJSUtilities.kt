package com.salesforce.nimbusjs

import android.content.Context
import android.util.Log
import android.webkit.WebView
import java.io.*
import java.nio.charset.StandardCharsets

class NimbusJSUtilities() {
    companion object Injection {

        fun injectedNimbusStream(inputStream: InputStream, context: Context): InputStream {
            val jsString = ResourceUtils(context).stringFromRawResource(R.raw.nimbus)
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

private fun String.Companion.fromStream(stream: InputStream): String {
    val result = ByteArrayOutputStream()
    val buffer = ByteArray(1024)
    var length = stream.read(buffer)
    while (length != -1) {
        result.write(buffer, 0, length)
        length = stream.read(buffer)
    }
    return result.toString(StandardCharsets.UTF_8.name())
}

private class ResourceUtils(val context: Context) {
    fun stringFromRawResource(id: Int): String {
        val inputStream = context.resources.openRawResource(id)
        val string = String.fromStream(inputStream)
        return string
    }
}