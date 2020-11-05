//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import java.util.concurrent.Callable
import java.util.concurrent.ScheduledExecutorService

/**
 * Unit tests for [V8Extensions].
 */
class V8ExtensionsTest {

    lateinit var mV8: V8

    /**
     * mocked v8 executor service to make v8 to run on test thread to avoid test flaking due to timing
     */
    val mockedV8ExecutorService = mockk<ScheduledExecutorService> {
        val v8CallableSlot = slot<Callable<V8>>()
        every { submit(capture(v8CallableSlot)) } answers {
            mockk { every { get() } returns v8CallableSlot.captured.call() }
        }

        val runnableSlot1 = slot<Runnable>()
        every { submit(capture(runnableSlot1)) } answers {
            mockk { every { get() } answers { runnableSlot1.captured.run() } }
        }

        val runnableSlot2 = slot<Runnable>()
        every { execute(capture(runnableSlot2)) } answers { runnableSlot2.captured.run() }

        val runnableSlot3 = slot<Runnable>()
        every { schedule(capture(runnableSlot3), any(), any()) } answers {
            mockk {
                runnableSlot3.captured.run()
                every { get() } answers {
                    runnableSlot3.captured.run()
                }
                every { isDone } returns false
                every { cancel(any()) } returns true
            }
        }
    }

    @Before
    fun setup() {
        mV8 = mockedV8ExecutorService.submit(Callable {
            V8.createV8Runtime("globalThis")
        }).get()
    }

    @After
    fun cleanup() {
        mV8.close()
    }

    @Test
    fun resolvePromiseReferenceMaintainedTest() {
        Assert.assertEquals(0, mV8.objectReferenceCount)
        val promise = mV8.resolvePromise("string")
        Assert.assertEquals(1, mV8.objectReferenceCount)
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }

    @Test
    fun resolvePromiseStringResultTest() {
        val promise = mV8.resolvePromise("string")
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }

    @Test
    fun resolvePromiseUnitResultTest() {
        val promise = mV8.resolvePromise(Unit)
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }

    @Test
    fun rejectPromiseReferenceMaintainedTest() {
        Assert.assertEquals(0, mV8.objectReferenceCount)
        val promise = mV8.rejectPromise("message")
        Assert.assertEquals(1, mV8.objectReferenceCount)
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }

    @Test
    fun rejectPromiseStringResultTest() {
        val promise = mV8.rejectPromise("message")
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }

    @Test
    fun rejectPromiseUnitResultTest() {
        val promise = mV8.rejectPromise(Unit)
        promise.close()
        Assert.assertEquals(0, mV8.objectReferenceCount)
    }
}
