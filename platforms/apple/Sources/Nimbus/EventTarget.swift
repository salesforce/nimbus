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

private typealias Listener = (Int) -> Void
private typealias ListenerMap = [String: Listener]

class EventTarget<Events: EventKeyPathing> {
    private var listeners: [String: ListenerMap] = [:]

    func addEventListener(name: String, listener: @escaping (Int) -> Void) -> String {
        let listenerId = UUID().uuidString
        var listenerMap: ListenerMap = [:]
        if let map = listeners[name] {
            listenerMap = map
        }
        listenerMap[listenerId] = listener
        listeners[name] = listenerMap
        return listenerId
    }

    func removeEventListener(listenerId: String) {
        listeners.forEach { key, map in
            listeners[key] = map.filter { key, _ in
                key != listenerId
            }
        }
    }

    func publishEvent<V: Encodable>(_ eventKeyPath: KeyPath<Events, V>, payload: V) {
        guard let eventName = Events.stringForKeyPath(eventKeyPath),
            let map = listeners[eventName] else {
            return
        }

        map.forEach { _, listener in
            listener(0)
        }
    }

    func bind(to connection: Connection) {
        connection.bind(addEventListener, as: "addEventListener")
        connection.bind(removeEventListener, as: "removeEventListener")
    }
}
