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
    var testPlugin: ConnectionTestPlugin = ConnectionTestPlugin()

    override func setUp() {
        expectationPlugin = ExpectationPlugin()
        context = JSContext()
        bridge = JSContextBridge()
        bridge.addPlugin(expectationPlugin)
        let current = expectation(description: self.name)
        expectationPlugin.currentExpectation = current
        testPlugin = ConnectionTestPlugin()
        bridge.addPlugin(testPlugin)
        bridge.attach(to: context)
    }

    class ConnectionTestPlugin: Plugin {
        var receivedInt: Int?
        var receivedStruct: TestStruct?

        func bind<C>(to connection: C) where C: Connection {
            connection.bind(self.anInt, as: "anInt")
            connection.bind(self.arrayOfInts, as: "arrayOfInts")
            connection.bind(self.aStruct, as: "aStruct")
            connection.bind(self.intParameter, as: "intParameter")
            connection.bind(self.structParameter, as: "structParameter")
        }

        func anInt() -> Int {
            return 5
        }

        func arrayOfInts() -> [Int] {
            return [1, 2, 3]
        }

        func aStruct() -> TestStruct {
            return TestStruct(foo: "foostring", bar: 10)
        }

        func intParameter(number: Int) {
            receivedInt = number
        }

        func structParameter(thing: TestStruct) {
            receivedStruct = thing
        }
    }

    struct TestStruct: Codable {
        let foo: String
        let bar: Int

        init(foo: String, bar: Int) {
            self.foo = foo
            self.bar = bar
        }
    }

    func testSimpleBinding() throws {
        let testScript = """
        function checkResult(result) {
            if (result !== 5) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
        }
        __nimbus.plugins.ConnectionTestPlugin.anInt().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testArrayBinding() throws {
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
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            if (result[2] !== 3) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
        }
        __nimbus.plugins.ConnectionTestPlugin.arrayOfInts().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testStructBinding() throws {
        let testScript = """
        function checkResult(result) {
            if (result.foo !== "foostring") {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            if (result.bar !== 10) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
        }
        __nimbus.plugins.ConnectionTestPlugin.aStruct().then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testIntParameter() throws {
        let testScript = """
        function checkResult() {
            __nimbus.plugins.ExpectationPlugin.pass();
        }
        __nimbus.plugins.ConnectionTestPlugin.intParameter(11).then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
        XCTAssertEqual(testPlugin.receivedInt, 11)
    }

    func testStructParameter() throws {
        let testScript = """
        var thing = { "foo": "stringfoo", "bar": 12 };
        function checkResult() {
            __nimbus.plugins.ExpectationPlugin.pass();
        }
        __nimbus.plugins.ConnectionTestPlugin.structParameter(thing).then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 10)
        XCTAssertTrue(expectationPlugin.passed)
        XCTAssertEqual(testPlugin.receivedStruct?.foo, "stringfoo")
        XCTAssertEqual(testPlugin.receivedStruct?.bar, 12)
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

    func currentExpectations() -> [XCTestExpectation] {
        if let current = currentExpectation {
            return [current]
        }
        return []
    }
}
