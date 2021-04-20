//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.*
import com.salesforce.k2v8.scope
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.Ignore
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService

/**
 * Unit tests for [Promise].
 */
class PromiseTest {


    private lateinit var v8: V8

    var resolvedValue: String? = null
    var rejectedValue: String? = null

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()

        rejectedValue = null
        resolvedValue = null
    }

    @After
    fun tearDown() {
        v8.close()
    }

    @Test
    fun resolvePendingPromiseTest() = v8.scope {
        val startRefCount = v8.objectReferenceCount
        val data = "resolved value 1"

        Promise.newPromise(v8).apply {
            then(
                { data -> resolvedValue = data },
                { reason -> rejectedValue = reason }
            )
            resolve(data)
            close()
        }

        Assert.assertEquals(data, resolvedValue)
        Assert.assertNull(rejectedValue)
        Assert.assertEquals(startRefCount, v8.objectReferenceCount)
    }

    @Test
    fun rejectPendingPromiseTest() = v8.scope {

        val startRefCount = v8.objectReferenceCount
        val rejectReason = "no reason"
        Promise.newPromise(v8).apply {
            then(
                { data -> resolvedValue = data },
                { reason -> rejectedValue = reason }
            )
            reject(rejectReason)
            close()
        }

        Assert.assertNull(resolvedValue)
        Assert.assertEquals(rejectReason, rejectedValue)
        Assert.assertEquals(startRefCount, v8.objectReferenceCount)
    }

    @Test
    fun fromJsPromiseTest() = v8.scope {

        val startRefCount = v8.objectReferenceCount

        val jsPromise = v8.resolvePromise("abc")

        Promise.from(jsPromise).apply {
            then(
                { data -> resolvedValue = data },
                { reason -> rejectedValue = reason }
            )
            close()
        }
        jsPromise.close()
        Assert.assertEquals("abc", resolvedValue)
        Assert.assertNull(rejectedValue)
        //Assert.assertEquals(startRefCount, v8.objectReferenceCount)
    }

    @Test(expected = UnsupportedOperationException::class)
    fun promiseOfWithInvalidV8Object() = v8.scope {
        val startRefCount = v8.objectReferenceCount
        Promise.from(V8Object(v8))
        Assert.assertEquals(startRefCount, v8.objectReferenceCount)
    }

    @Test(expected = UnsupportedOperationException::class)
    fun jsPromiseDoesNotSupportResolve() = v8.scope {
        val jsPromise = v8.resolvePromise("abc")
        Promise.from(jsPromise).resolve("abcAgain")
    }

    @Test(expected = UnsupportedOperationException::class)
    fun jsPromiseDoesNotSupportReject() = v8.scope {
        val jsPromise = v8.resolvePromise("abc")
        Promise.from(jsPromise).resolve("abcAgain")
    }
}
