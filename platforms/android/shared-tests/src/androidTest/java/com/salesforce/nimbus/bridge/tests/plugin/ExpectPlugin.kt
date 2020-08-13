//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.tests.plugin

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import java.util.concurrent.CountDownLatch

// ExpectPlugin is marked internal so we can test with visibility other than "public"
@PluginOptions("expectPlugin")
internal class ExpectPlugin : Plugin {

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
