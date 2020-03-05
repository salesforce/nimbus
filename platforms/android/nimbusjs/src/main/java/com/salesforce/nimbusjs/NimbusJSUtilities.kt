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
                if (it.contains("</head>")) {
                    html.replace("</head>", "<script>\n$jsString\n</script>\n</head>")
                } else if (it.contains("<body>")) {
                    html.replace("<body>", "<script>\n$jsString\n</script>\n<body>")
                } else if (it.contains("<html>")) {
                    html.replace("<html>", "<html><script>\n$jsString\n</script>")
                } else {
                    throw Exception("Can't find any of <html>, </head>, or <body> to inject nimbus")
                }
            }

            return ByteArrayInputStream(replacedHtml.toByteArray(StandardCharsets.UTF_8))
        }
    }
}
