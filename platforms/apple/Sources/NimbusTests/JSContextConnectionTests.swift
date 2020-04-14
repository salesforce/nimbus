// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest
@testable import Nimbus
import JavaScriptCore

class JSContextConnectionTests: XCTestCase {
    var context: JSContext = JSContext()
    var bridge: JSContextBridge = JSContextBridge()
    var expectationPlugin: ExpectationPlugin = ExpectationPlugin()

    override func setUp() {
        expectationPlugin = ExpectationPlugin()
        context = JSContext()
        bridge = JSContextBridge()
        bridge.addPlugin(expectationPlugin)
    }

    private class ConnectionTestPlugin: Plugin {
        func bind<C>(to connection: C) where C: Connection {
            connection.bind(self.anInt, as: "anInt")
            connection.bind(self.arrayOfInts, as: "arrayOfInts")
            connection.bind(self.aStruct, as: "aStruct")
        }

        func anInt() -> Int {
            return 5
        }

        func arrayOfInts() -> [Int] {
            return [1, 2, 3]
        }

        func aStruct() -> TestStruct {
            return TestStruct()
        }
    }

    struct TestStruct: Encodable {
        let foo = "foostring"
        let bar = 10
    }

    func testSimpleBinding() throws {
        let current = expectation(description: "simple binding")
        expectationPlugin.currentExpectation = current
        let plugin = ConnectionTestPlugin()
        bridge.addPlugin(plugin)
        bridge.attach(to: context)
        let testScript = """
        function checkResult(result) {
            if (result !== 5) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass()
        }
        __nimbus.plugins.ConnectionTestPlugin.anInt().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: [current], timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testArrayBinding() throws {
        let current = expectation(description: "array binding")
        expectationPlugin.currentExpectation = current
        let plugin = ConnectionTestPlugin()
        bridge.addPlugin(plugin)
        bridge.attach(to: context)
        let testScript = """
        function checkResult(result) {
            if (result.length !== 3) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            if (result[0] !== 1) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            if (result[1] !== 2) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            if (result[2] !== 3) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass()
        }
        __nimbus.plugins.ConnectionTestPlugin.arrayOfInts().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: [current], timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testStructBinding() throws {
        let current = expectation(description: "struct binding")
        expectationPlugin.currentExpectation = current
        let plugin = ConnectionTestPlugin()
        bridge.addPlugin(plugin)
        bridge.attach(to: context)
        let testScript = """
        function checkResult(result) {
            if (result.foo !== "foostring") {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            if (result.bar !== 10) {
                __nimbus.plugins.ExpectationPlugin.fail()
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass()
        }
        __nimbus.plugins.ConnectionTestPlugin.aStruct().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: [current], timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }
}

class ExpectationPlugin: Plugin {
    var currentExpectation: XCTestExpectation?
    var passed = false

    func bind<C>(to connection: C) where C: Connection {
        connection.bind(self.fail, as: "fail")
        connection.bind(self.pass, as: "pass")
    }

    func fail() {
        passed = false
        currentExpectation?.fulfill()
    }

    func pass() {
        passed = true
        currentExpectation?.fulfill()
    }
}
