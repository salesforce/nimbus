//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import com.salesforce.nimbus.Extension
import com.salesforce.nimbus.ExtensionMethod
import com.salesforce.nimbus.JSONSerializable
import com.salesforce.nimbus.NimbusExtension
import org.json.JSONObject
import java.util.Date

@Extension(name = "DemoBridge")
class SimpleBridgeExtension : NimbusExtension {

    data class Foo(val name: String, val title: String): JSONSerializable {
        override fun stringify(): String {
            val jsonObject = JSONObject()
            jsonObject.put("name", name)
            jsonObject.put("title", title)
            return jsonObject.toString()
        }

        companion object {
            @JvmStatic
            fun fromJSON(jsonString: String): Foo {
                val json = JSONObject(jsonString)
                val name = json.optString("name", "name")
                val title = json.optString("title", "title")
                return Foo(name, title)
            }
        }
    }

    @ExtensionMethod
    fun currentTime(): String {
        return Date().toString()
    }

    @ExtensionMethod
    fun anotherMethod(arg: String, arg2: Int, arg3: Foo): String {
        return ""
    }

    @ExtensionMethod
    fun voidReturn(arg: Int) {

    }

    @ExtensionMethod
    fun funArg(arg: (String, Int) -> Void) {
        arg("result", 37)
    }

    @ExtensionMethod
    fun nullableFunArg(arg: (String?, String?) -> Unit) {
        arg("result", null)
    }

    @ExtensionMethod
    fun serializable(): Foo {
        return Foo("Astro", "mascot")
    }
}