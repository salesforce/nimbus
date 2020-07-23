//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.booleans.shouldBeFalse
import io.kotest.matchers.booleans.shouldBeTrue
import kotlinx.serialization.Serializable
import kotlin.properties.Delegates

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

class DefaultEventPublisherTest : StringSpec({
    lateinit var eventPublisher: DefaultEventPublisher<TestEvents>
    var eventOneListenerCalledWithCorrectData by Delegates.notNull<Boolean>()
    lateinit var eventOneListenerId: String
    var eventTwoListenerCalledWithCorrectData by Delegates.notNull<Boolean>()
    lateinit var eventTwoListenerId: String

    beforeTest {
        eventOneListenerCalledWithCorrectData = false
        eventTwoListenerCalledWithCorrectData = false
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

    "TestEventOne listener is invoked" {

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener received correct data
        eventOneListenerCalledWithCorrectData.shouldBeTrue()

        // reset
        eventOneListenerCalledWithCorrectData = false

        // publish another event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener received correct data again
        eventOneListenerCalledWithCorrectData.shouldBeTrue()
    }

    "TestEventTwo listener is invoked" {

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener received correct data
        eventTwoListenerCalledWithCorrectData.shouldBeTrue()

        // reset
        eventTwoListenerCalledWithCorrectData = false

        // publish another event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener received correct data again
        eventTwoListenerCalledWithCorrectData.shouldBeTrue()
    }

    "TestEventOne listener is not invoked after removed" {

        // remove listener
        eventPublisher.removeListener(eventOneListenerId)

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventOne(message = "testMessage"))

        // make sure listener was never called
        eventOneListenerCalledWithCorrectData.shouldBeFalse()
    }

    "TestEventTwo listener is not invoked after removed" {

        // remove listener
        eventPublisher.removeListener(eventTwoListenerId)

        // publish event
        eventPublisher.publishEvent(TestEvents.TestEventTwo(thingOne = 1, thingTwo = true))

        // make sure listener was never called
        eventTwoListenerCalledWithCorrectData.shouldBeFalse()
    }
})
