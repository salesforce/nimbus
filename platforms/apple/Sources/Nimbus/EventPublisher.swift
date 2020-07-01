//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation

/**
 Conformers to this protocol provide a mapping from a key path to a string
 representation of the property name
 */
public protocol EventKeyPathing {
    static func stringForKeyPath(_ keyPath: PartialKeyPath<Self>) -> String?
}

private typealias Listener = (Encodable) -> Void
private typealias ListenerMap = [String: Listener]

/**
 A mix-in class to add event publishing capabilities to a plugin.

 Instantiate with a type conforming to EventKeyPathing and call
 this instance's bind function in your plugin's bind, passing in the
 Connection, and javascript consumers can subscribe/unsubscribe
 to events in your plugin. Publish events by passing a keyPath with
 appropriate object as value to send events to listeners of that event.
 */
public class EventPublisher<Events: EventKeyPathing> {
    private var listeners: [String: ListenerMap] = [:]
    private var listenerQueue: DispatchQueue = DispatchQueue(label: "EventPublisher")

    /**
     Adds a listener for the given event name. This function is bound
     in the bind method and shouldn't be called directly.
     */
    func addListener(name: String, listener: @escaping (Encodable) -> Void) -> String {
        let listenerId = UUID().uuidString
        listenerQueue.sync {
            var listenerMap: ListenerMap = listeners[name, default: [:]]
            listenerMap[listenerId] = listener
            listeners[name] = listenerMap
        }
        return listenerId
    }

    /**
     Removes the given listener so it won't receive future events.
     This function is bound in the bind method and shouldn't be called directly.
     */
    func removeListener(listenerId: String) {
        listenerQueue.sync {
            listeners = listeners.mapValues { map in
                var updatedListeners = map
                updatedListeners.removeValue(forKey: listenerId)
                return updatedListeners
            }
        }
    }

    /**
     Publishes the given event with the given payload.
     */
    func publishEvent<V: Codable>(_ eventKeyPath: KeyPath<Events, V>, payload: V) {
        listenerQueue.sync {
            guard let eventName = Events.stringForKeyPath(eventKeyPath),
                let map = listeners[eventName] else {
                return
            }
            map.forEach { _, listener in
                listener(payload)
            }
        }
    }

    /**
     Call this method from your plugins bind method.
     */
    func bind(to connection: Connection) {
        connection.bind(addListener, as: "addListener")
        connection.bind(removeListener, as: "removeListener")
    }
}
