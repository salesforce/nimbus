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

struct EventTarget<T> {
    func addEventListener() -> String {
        return ""
    }

    func removeEventListener(listenerId: String) {

    }

    func dispatchEvent<T: Event>(event: T) {

    }

    func bind(to connection: Connection) {

    }
}
