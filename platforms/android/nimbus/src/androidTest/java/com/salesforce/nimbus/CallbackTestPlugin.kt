package com.salesforce.nimbus

import org.json.JSONArray
import org.json.JSONObject

@PluginOptions(name = "callbackTestPlugin")
class CallbackTestPlugin : Plugin {
    @BoundMethod
    fun callbackWithSingleParam(arg: (param0: MochaTests.MochaMessage) -> Unit) {
        arg(MochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithTwoParams(arg: (param0: MochaTests.MochaMessage, param1: MochaTests.MochaMessage) -> Unit) {
        var mochaMessage = MochaTests.MochaMessage("int param is 6", 6)
        arg(MochaTests.MochaMessage(), mochaMessage)
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
    fun callbackWithPrimitiveAndUddtParams(arg: (param0: Int, param1: MochaTests.MochaMessage) -> Unit) {
        arg(777, MochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithPrimitiveAndArrayParams(arg: (param0: Int, param1: JSONArray) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(777, ja)
    }

    @BoundMethod
    fun callbackWithPrimitiveAndDictionaryParams(arg: (param0: Int, param1: JSONObject) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(777, jo)
    }

    @BoundMethod
    fun callbackWithArrayAndUddtParams(arg: (param0: JSONArray, param1: MochaTests.MochaMessage) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(ja, MochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithArrayAndArrayParams(arg: (param0: JSONArray, param1: JSONArray) -> Unit) {
        var ja0 = JSONArray(listOf("one", "two", "three"))
        var ja1 = JSONArray(listOf("four", "five", "six"))
        arg(ja0, ja1)
    }

    @BoundMethod
    fun callbackWithArrayAndDictionaryParams(arg: (param0: JSONArray, param1: JSONObject) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(ja, jo)
    }

    @BoundMethod
    fun callbackWithDictionaryAndUddtParams(arg: (param0: JSONObject, param1: MochaTests.MochaMessage) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(jo, MochaTests.MochaMessage())
    }

    @BoundMethod
    fun callbackWithDictionaryAndArrayParams(arg: (param0: JSONObject, param1: JSONArray) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(jo, ja)
    }

    @BoundMethod
    fun callbackWithDictionaryAndDictionaryParams(arg: (param0: JSONObject, param1: JSONObject) -> Unit) {
        var jo0 = JSONObject()
        jo0.put("one", 1)
        jo0.put("two", 2)
        jo0.put("three", 3)
        var jo1 = JSONObject()
        jo1.put("four", 4)
        jo1.put("five", 5)
        jo1.put("six", 6)
        arg(jo0, jo1)
    }

    @BoundMethod
    fun callbackWithSingleParamAndReturn(arg: (param0: MochaTests.MochaMessage) -> Unit): String {
        arg(MochaTests.MochaMessage())
        return "one"
    }

    @BoundMethod
    fun callbackWithSinglePrimitiveParamAndReturn(arg: (param0: Int) -> Unit): String {
        arg(777)
        return "one"
    }

    @BoundMethod
    fun callbackWithTwoParamAndReturn(arg: (param0: MochaTests.MochaMessage, param1: MochaTests.MochaMessage) -> Unit): String {
        var mochaMessage = MochaTests.MochaMessage("mock", 3)
        arg(MochaTests.MochaMessage(), mochaMessage)
        return "two"
    }

    @BoundMethod
    fun callbackWithTwoPrimitiveParamAndReturn(arg: (param0: Int, param1: Int) -> Unit): String {
        arg(1, 2)
        return "two"
    }
}
