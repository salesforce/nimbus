//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Default implementation of [EventPublisher].
 */
class DefaultEventPublisher<E : Event> : EventPublisher<E> {
    private val listeners: MutableMap<String, MutableMap<String, (E) -> Unit>> = ConcurrentHashMap()

    /**
     * @see [EventPublisher.publishEvent]
     */
    override fun publishEvent(event: E) {
        listeners[event.name]?.values?.forEach { listener -> listener(event) }
    }

    /**
     * @see [EventPublisher.addListener]
     */
    override fun addListener(eventName: String, listener: (E) -> Unit): String {

        // create a UUID to return so that the listener can later be removed
        val listenerId = UUID.randomUUID().toString()

        // get our map of listenerId -> listener by event name
        val listenerMap = listeners.getOrPut(eventName) { mutableMapOf() }

        // add the new listener to the map
        listenerMap[listenerId] = listener

        // return the UUID
        return listenerId
    }

    /**
     * @see [EventPublisher.removeListener]
     */
    override fun removeListener(listenerId: String) {
        listeners.values.forEach { listenerMap -> listenerMap.remove(listenerId) }
    }
}
