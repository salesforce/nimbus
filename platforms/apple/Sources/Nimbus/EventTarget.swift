//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

protocol Event: Codable {
    associatedtype EventType: RawRepresentable where EventType.RawValue == String
    var type: EventType { get }
}

typealias Listener = (Int) -> Void
typealias ListenerMap = [String: Listener]

class EventTarget<T: Event> {
    private var listeners: [String: ListenerMap] = [:]
    func addEventListener(name: T, listener: @escaping (Int) -> Void) -> String {
        let listenerId = UUID().uuidString
        var listenerMap: ListenerMap = [:]
        if let map = listeners[name.type.rawValue] {
            listenerMap = map
        }
        listenerMap[listenerId] = listener
        listeners[name.type.rawValue] = listenerMap
        return listenerId
    }

    func removeEventListener(listenerId: String) {
        listeners.forEach { (key, map) in
            listeners[key] = map.filter { (key, _) in
                return key != listenerId
            }
        }
    }

    func dispatchEvent(event: String) {
        if let map = listeners[event] {
            map.forEach { (_, listener) in
                listener(0)
            }
        }
    }

    func bind(to connection: Connection) {
        connection.bind(addEventListener, as: "addEventListener")
        connection.bind(removeEventListener, as: "removeEventListener")
        connection.bind(dispatchEvent, as: "dispatchEvent")
    }
}
