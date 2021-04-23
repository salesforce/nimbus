//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.salesforce.k2v8.scope
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.Ignore

/**
 * Unit tests for [V8Extensions].
 */
class V8ExtensionsTest {

    private lateinit var v8: V8

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()
    }

    @After
    fun tearDown() {
        v8.close()
    }

    @Test
    fun resolvePromiseReferenceMaintainedTest() = v8.scope {
        Assert.assertEquals(0, v8.objectReferenceCount)
        val promise = v8.resolvePromise("string")
        Assert.assertEquals(1, v8.objectReferenceCount)
        promise.close()
        Assert.assertEquals(0, v8.objectReferenceCount)
    }

    @Test
    fun resolvePromiseStringResultTest() = v8.scope {
        val promise = v8.resolvePromise("string")
        promise.close()
    }

    @Test
    fun resolvePromiseUnitResultTest() = v8.scope {
        val promise = v8.resolvePromise(Unit)
        promise.close()
    }

    @Test
    fun rejectPromiseReferenceMaintainedTest() {
        Assert.assertEquals(0, v8.objectReferenceCount)
        val promise = v8.rejectPromise("message")
        Assert.assertEquals(1, v8.objectReferenceCount)
        promise.close()
        Assert.assertEquals(0, v8.objectReferenceCount)
    }

    @Test
    fun rejectPromiseStringResultTest() = v8.scope {
        val promise = v8.rejectPromise("message")
        promise.close()
    }

    @Test
    fun rejectPromiseUnitResultTest() = v8.scope {
        val promise = v8.rejectPromise(Unit)
        promise.close()
    }
}
