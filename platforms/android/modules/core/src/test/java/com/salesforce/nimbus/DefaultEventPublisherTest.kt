//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import kotlinx.serialization.Serializable
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

sealed class TestEvents : Event {

    @Serializable
    data class TestEventOne(val message: String) : TestEvents() {
        override val name: String = "testEventOne"
    }

    @Serializable
    data class TestEventTwo(val thingOne: Int, val thingTwo: Boolean) : TestEvents() {
        override val name: String = "testEventTwo"
    }
}

class DefaultEventPublisherTest {
    private lateinit var eventPublisher: DefaultEventPublisher<TestEvents>
    private var eventOneListenerCalledWithCorrectData = false
    private lateinit var eventOneListenerId: String
    private var eventTwoListenerCalledWithCorrectData = false
    private lateinit var eventTwoListenerId: String

    @Before
    fun setUp() {
        eventPublisher = DefaultEventPublisher<TestEvents>().apply {
            eventOneListenerId = addListener("testEventOne") {
                eventOneListenerCalledWithCorrectData =
                    it is TestEvents.TestEventOne && it.message == "testMessage"
            }
            eventTwoListenerId = addListener("testEventTwo") {
                eventTwoListenerCalledWithCorrectData =
                    it is TestEvents.TestEventTwo && it.thingOne == 1 && it.thingTwo == true
            }
        }
    }

    @Test
    fun `TestEventOne listener is invoked`() {

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener received correct data
        assertTrue(eventOneListenerCalledWithCorrectData)

        // reset
        eventOneListenerCalledWithCorrectData = false

        // publish another event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener received correct data again
        assertTrue(eventOneListenerCalledWithCorrectData)
    }

    @Test
    fun `TestEventTwo listener is invoked`() {

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener received correct data
        assertTrue(eventTwoListenerCalledWithCorrectData)

        // reset
        eventTwoListenerCalledWithCorrectData = false

        // publish another event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener received correct data again
        assertTrue(eventTwoListenerCalledWithCorrectData)
    }

    @Test
    fun `TestEventOne listener is not invoked after removed`() {

        // remove listener
        eventPublisher.removeListener(eventOneListenerId)

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener was never called
        assertFalse(eventOneListenerCalledWithCorrectData)
    }

    @Test
    fun `TestEventTwo listener is not invoked after removed`() {

        // remove listener
        eventPublisher.removeListener(eventTwoListenerId)

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener was never called
        assertFalse(eventTwoListenerCalledWithCorrectData)
    }
}
