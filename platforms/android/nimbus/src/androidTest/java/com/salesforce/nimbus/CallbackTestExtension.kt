package com.salesforce.nimbus

import org.json.JSONArray
import org.json.JSONObject

@Extension(name = "callbackTestExtension")
class CallbackTestExtension : NimbusExtension {
    @ExtensionMethod
    fun callbackWithSingleParam(arg: (param0: MochaTests.MochaMessage) -> Unit) {
        arg(MochaTests.MochaMessage())
    }

    @ExtensionMethod
    fun callbackWithTwoParams(arg: (param0: MochaTests.MochaMessage, param1: MochaTests.MochaMessage) -> Unit) {
        var mochaMessage = MochaTests.MochaMessage("int param is 6", 6)
        arg(MochaTests.MochaMessage(), mochaMessage)
    }

    @ExtensionMethod
    fun callbackWithSinglePrimitiveParam(arg: (param0: Int) -> Unit) {
        arg(777)
    }

    @ExtensionMethod
    fun callbackWithTwoPrimitiveParams(arg: (param0: Int, param1: Int) -> Unit) {
        arg(777, 888)
    }

    @ExtensionMethod
    fun callbackWithPrimitiveAndUddtParams(arg: (param0: Int, param1: MochaTests.MochaMessage) -> Unit) {
        arg(777, MochaTests.MochaMessage())
    }

    @ExtensionMethod
    fun callbackWithPrimitiveAndArrayParams(arg: (param0: Int, param1: JSONArray) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(777, ja)
    }

    @ExtensionMethod
    fun callbackWithPrimitiveAndDictionaryParams(arg: (param0: Int, param1: JSONObject) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(777, jo)
    }

    @ExtensionMethod
    fun callbackWithArrayAndUddtParams(arg: (param0: JSONArray, param1: MochaTests.MochaMessage) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(ja, MochaTests.MochaMessage())
    }

    @ExtensionMethod
    fun callbackWithArrayAndArrayParams(arg: (param0: JSONArray, param1: JSONArray) -> Unit) {
        var ja0 = JSONArray(listOf("one", "two", "three"))
        var ja1 = JSONArray(listOf("four", "five", "six"))
        arg(ja0, ja1)
    }

    @ExtensionMethod
    fun callbackWithArrayAndDictionaryParams(arg: (param0: JSONArray, param1: JSONObject) -> Unit) {
        var ja = JSONArray(listOf("one", "two", "three"))
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(ja, jo)
    }

    @ExtensionMethod
    fun callbackWithDictionaryAndUddtParams(arg: (param0: JSONObject, param1: MochaTests.MochaMessage) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        arg(jo, MochaTests.MochaMessage())
    }

    @ExtensionMethod
    fun callbackWithDictionaryAndArrayParams(arg: (param0: JSONObject, param1: JSONArray) -> Unit) {
        var jo = JSONObject()
        jo.put("one", 1)
        jo.put("two", 2)
        jo.put("three", 3)
        var ja = JSONArray(listOf("one", "two", "three"))
        arg(jo, ja)
    }

    @ExtensionMethod
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
}
