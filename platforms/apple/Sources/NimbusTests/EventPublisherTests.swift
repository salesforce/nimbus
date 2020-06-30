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

class EventPublisherTests: XCTestCase {
    var target = EventPublisher<TestEvents>()

    override func setUp() {
        target = EventPublisher<TestEvents>()
    }

    struct TestEventOne: Codable {
        var message: String
    }

    struct TestEventTwo: Codable {
        var thingOne: Int
        var thingTwo: Bool
    }

    struct TestEvents: EventKeyPathing {
        var testEventOne: TestEventOne
        var testEventTwo: TestEventTwo
        var testEventThree: String

        static func stringForKeyPath(_ keyPath: PartialKeyPath<Self>) -> String? {
            switch keyPath {
            case \TestEvents.testEventOne: return "testEventOne"
            case \TestEvents.testEventTwo: return "testEventTwo"
            case \TestEvents.testEventThree: return "testEventThree"
            default:
                return nil
            }
        }
    }

    func testBinding() {
        // Verify that EventTarget actually binds its methods to a connection
        let connection = TestConnection(from: JSContext(), bridge: JSContextBridge(), as: "test")
        target.bind(to: connection)
        XCTAssertEqual(connection.boundNames.count, 2)
        XCTAssertTrue(connection.boundNames.contains("addEventListener"))
        XCTAssertTrue(connection.boundNames.contains("removeEventListener"))
    }

    func testDispatch() {
        let exp = expectation(description: "dispatch")
        // Add a listener
        _ = target.addEventListener(name: "testEventOne") { result in
            XCTAssertTrue(result is TestEventOne)
            exp.fulfill()
        }
        // Dispatch an event
        target.publishEvent(\.testEventOne, payload: TestEventOne(message: "testMessage"))
        // verify listener is called
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemoveListener() {
        var exp = expectation(description: "dispatch")
        // Add a listener
        let listenerId = target.addEventListener(name: "testEventOne") { result in
            XCTAssertTrue(result is TestEventOne)
            exp.fulfill()
        }
        // Dispatch an event
        target.publishEvent(\.testEventOne, payload: TestEventOne(message: "testMessage"))
        // verify listener is called
        waitForExpectations(timeout: 1, handler: nil)
        // remove listener
        target.removeEventListener(listenerId: listenerId)
        exp = expectation(description: "inverted")
        exp.isInverted = true
        // dispatch event
        target.publishEvent(\.testEventOne, payload: TestEventOne(message: "testMessage"))
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
