package com.salesforce.nimbus.bridge.tests.plugin

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import java.util.concurrent.CountDownLatch

@PluginOptions("expectPlugin")
class ExpectPlugin : Plugin {

    val testReady = CountDownLatch(1)
    val testFinished = CountDownLatch(1)
    var passed = false

    @BoundMethod
    fun ready() {
        testReady.countDown()
    }

    @BoundMethod
    fun pass() {
        passed = true
    }

    @BoundMethod
    fun finished() {
        testFinished.countDown()
    }
}
