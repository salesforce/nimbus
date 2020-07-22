//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

/**
 * Defines a [Plugin] which can publish [Event]s of type [E] to a listener who has subscribed to those events.
 */
interface EventPublisher<E : Event> {

    /**
     * Publishes an event [E] to any listeners which are subscribed to the [Event.name].
     */
    fun publishEvent(event: E)

    /**
     * Add a listener for events with the [eventName] specified.
     *
     * @return a UUID which can later be used to remove the listener via [removeListener]
     */
    fun addListener(eventName: String, listener: (E) -> Unit): String

    /**
     * Removes a listener using the UUID returned from [addListener].
     */
    fun removeListener(listenerId: String)
}
