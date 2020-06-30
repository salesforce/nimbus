//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation

protocol EventKeyPathing {
    static func stringForKeyPath(_ keyPath: PartialKeyPath<Self>) -> String?
}

private typealias Listener = (Encodable) -> Void
private typealias ListenerMap = [String: Listener]

class EventPublisher<Events: EventKeyPathing> {
    private var listeners: [String: ListenerMap] = [:]

    func addListener(name: String, listener: @escaping (Encodable) -> Void) -> String {
        let listenerId = UUID().uuidString
        var listenerMap: ListenerMap = [:]
        if let map = listeners[name] {
            listenerMap = map
        }
        listenerMap[listenerId] = listener
        listeners[name] = listenerMap
        return listenerId
    }

    func removeListener(listenerId: String) {
        listeners.forEach { key, map in
            listeners[key] = map.filter { key, _ in
                key != listenerId
            }
        }
    }

    func publishEvent<V: Codable>(_ eventKeyPath: KeyPath<Events, V>, payload: V) {
        guard let eventName = Events.stringForKeyPath(eventKeyPath),
            let map = listeners[eventName] else {
            return
        }

        map.forEach { _, listener in
            listener(payload)
        }
    }

    func bind(to connection: Connection) {
        connection.bind(addListener, as: "addListener")
        connection.bind(removeListener, as: "removeListener")
    }
}
