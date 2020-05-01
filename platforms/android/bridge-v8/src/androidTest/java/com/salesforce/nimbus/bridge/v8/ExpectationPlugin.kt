package com.salesforce.nimbus.bridge.v8

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions

@PluginOptions("expect")
class ExpectationPlugin : Plugin {
    var passed = false

    @BoundMethod
    fun pass() {
        passed = true
    }

    @BoundMethod
    fun fail() {
        passed = false
    }
}
