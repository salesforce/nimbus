// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


package com.salesforce.veil

import android.content.Context
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.nio.charset.StandardCharsets

fun String.Companion.fromStream(stream: InputStream): String {
    val result = ByteArrayOutputStream()
    val buffer = ByteArray(1024)
    var length = stream.read(buffer)
    while (length != -1) {
        result.write(buffer, 0, length)
        length = stream.read(buffer)
    }
    return result.toString(StandardCharsets.UTF_8.name())
}

class ResourceUtils(val context: Context) {
    fun stringFromRawResource(id: Int): String {
        val inputStream = context.resources.openRawResource(id)
        val string = String.fromStream(inputStream)
        return string
    }
}
