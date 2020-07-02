package com.salesforce.nimbus.bridge.tests.plugin

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import java.util.concurrent.CountDownLatch

@PluginOptions("expectPlugin")
class ExpectPlugin : Plugin {

    var testReady = CountDownLatch(1)
        private set
    var testFinished = CountDownLatch(1)
        private set
    var passed = false
        private set

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

    fun reset() {
        testReady = CountDownLatch(1)
        testFinished = CountDownLatch(1)
        passed = false
    }
}
