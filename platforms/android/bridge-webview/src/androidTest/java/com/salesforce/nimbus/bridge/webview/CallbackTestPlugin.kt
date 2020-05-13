package com.salesforce.nimbus.bridge.webview

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import org.json.JSONArray
import org.json.JSONObject

@PluginOptions(name = "callbackTestPlugin")
class CallbackTestPlugin : Plugin {
    @BoundMethod
    fun callbackWithSingleParam(arg: (param0: WebViewMochaTests.MochaMessage) -> Unit) {
        arg(WebViewMochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithTwoParams(arg: (param0: WebViewMochaTests.MochaMessage, param1: WebViewMochaTests.MochaMessage) -> Unit) {
        val mochaMessage = WebViewMochaTests.MochaMessage("int param is 6", 6)
        arg(WebViewMochaTests.MochaMessage(), mochaMessage)
    }

    @BoundMethod
    fun callbackWithSinglePrimitiveParam(arg: (param0: Int) -> Unit) {
        arg(777)
    }

    @BoundMethod
    fun callbackWithTwoPrimitiveParams(arg: (param0: Int, param1: Int) -> Unit) {
        arg(777, 888)
    }

    @BoundMethod
    fun callbackWithPrimitiveAndUddtParams(arg: (param0: Int, param1: WebViewMochaTests.SerializableMochaMessage) -> Unit) {
        arg(777, WebViewMochaTests.SerializableMochaMessage())
    }

    @BoundMethod
    fun callbackWithPrimitiveAndArrayParams(arg: (param0: Int, param1: JSONArray) -> Unit) {
        val ja = JSONArray(listOf("one", "two", "three"))
        arg(777, ja)
    }

    @BoundMethod
    fun callbackWithPrimitiveAndDictionaryParams(arg: (param0: Int, param1: JSONObject) -> Unit) {
        val jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(777, jo)
    }

    @BoundMethod
    fun callbackWithArrayAndUddtParams(arg: (param0: JSONArray, param1: WebViewMochaTests.MochaMessage) -> Unit) {
        val ja = JSONArray(listOf("one", "two", "three"))
        arg(ja, WebViewMochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithArrayAndArrayParams(arg: (param0: JSONArray, param1: JSONArray) -> Unit) {
        val ja0 = JSONArray(listOf("one", "two", "three"))
        val ja1 = JSONArray(listOf("four", "five", "six"))
        arg(ja0, ja1)
    }

    @BoundMethod
    fun callbackWithArrayAndDictionaryParams(arg: (param0: JSONArray, param1: JSONObject) -> Unit) {
        val ja = JSONArray(listOf("one", "two", "three"))
        val jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(ja, jo)
    }

    @BoundMethod
    fun callbackWithDictionaryAndUddtParams(arg: (param0: JSONObject, param1: WebViewMochaTests.SerializableMochaMessage) -> Unit) {
        val jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(jo, WebViewMochaTests.SerializableMochaMessage())
    }

    @BoundMethod
    fun callbackWithDictionaryAndArrayParams(arg: (param0: JSONObject, param1: JSONArray) -> Unit) {
        val jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        val ja = JSONArray(listOf("one", "two", "three"))
        arg(jo, ja)
    }

    @BoundMethod
    fun callbackWithDictionaryAndDictionaryParams(arg: (param0: JSONObject, param1: JSONObject) -> Unit) {
        val jo0 = JSONObject()
        jo0.put("one", 1)
        jo0.put("two", 2)
        jo0.put("three", 3)
        val jo1 = JSONObject()
        jo1.put("four", 4)
        jo1.put("five", 5)
        jo1.put("six", 6)
        arg(jo0, jo1)
    }
}
