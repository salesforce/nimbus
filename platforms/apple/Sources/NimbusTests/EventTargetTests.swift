//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore
import XCTest
@testable import Nimbus

class EventTargetTests: XCTestCase {
    var target = EventTarget<TestEventType>()

    override func setUp() {
        target = EventTarget<TestEventType>()
    }

    enum TestEventType: String, Codable {
        case one
        case two
    }

    struct TestEventOne: Event {
        var type = TestEventType.one
    }

    struct TestEventTwo: Event {
        var type = TestEventType.two
    }

    func testBinding() {
        // Verify that EventTarget actually binds its methods to a connection
        let connection = TestConnection(from: JSContext(), bridge: JSContextBridge(), as: "test")
        target.bind(to: connection)
        XCTAssertEqual(connection.boundNames.count, 3)
        XCTAssertTrue(connection.boundNames.contains("addEventListener"))
        XCTAssertTrue(connection.boundNames.contains("removeEventListener"))
        XCTAssertTrue(connection.boundNames.contains("dispatchEvent"))
    }

    func testDispatch() {
        // Add a listener
        // Dispatch an event
        // verify listener is called
    }

    func testRemoveListener() {
        // Add a listener
        // Dispatch an event
        // verify listener is called
        // remove listener
        // dispatch event
        // verify listener is not called
    }

}

class TestConnection: JSContextConnection {
    var boundNames: [String] = []

    override func bindCallable(_ name: String, to callable: @escaping Callable) {
        boundNames.append(name)
        super.bindCallable(name, to: callable)
    }
}
