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
    var target = EventTarget<TestEvent>()

    override func setUp() {
        target = EventTarget<TestEvent>()
    }

    enum TestEventType: String, Codable {
        case one
        case two
    }

    struct TestEvent: Event, Codable {
        var type: TestEventType
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
        let exp = expectation(description: "dispatch")
        let event = TestEvent(type: .one)
        // Add a listener
        _ = target.addEventListener(name: event) { (_) in
            exp.fulfill()
        }
        // Dispatch an event
        target.dispatchEvent(event: TestEventType.one.rawValue)
        // verify listener is called
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemoveListener() {
        var exp = expectation(description: "dispatch")
        let event = TestEvent(type: .one)
        // Add a listener
        let listenerId = target.addEventListener(name: event) { (_) in
            exp.fulfill()
        }
        // Dispatch an event
        target.dispatchEvent(event: TestEventType.one.rawValue)
        // verify listener is called
        waitForExpectations(timeout: 1, handler: nil)
        // remove listener
        target.removeEventListener(listenerId: listenerId)
        exp = expectation(description: "inverted")
        exp.isInverted = true
        // dispatch event
        target.dispatchEvent(event: TestEventType.one.rawValue)
        // verify listener is not called
        waitForExpectations(timeout: 2, handler: nil)
    }

}

class TestConnection: JSContextConnection {
    var boundNames: [String] = []

    override func bindCallable(_ name: String, to callable: @escaping Callable) {
        boundNames.append(name)
        super.bindCallable(name, to: callable)
    }
}
