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

// swiftlint:disable type_body_length

class JSContextConnectionTests: XCTestCase {
    var context: JSContext = JSContext()
    var bridge: JSContextBridge = JSContextBridge()
    var expectationPlugin: ExpectationPlugin = ExpectationPlugin()
    var testPlugin: ConnectionTestPlugin = ConnectionTestPlugin()

    override func setUp() {
        expectationPlugin = ExpectationPlugin()
        testPlugin = ConnectionTestPlugin()
        context = JSContext()
        bridge = JSContextBridge()
        bridge.addPlugin(testPlugin)
        bridge.addPlugin(expectationPlugin)
    }

    func beginPluginTest() {
        let current = expectation(description: name)
        expectationPlugin.currentExpectation = current
        bridge.attach(to: context)
    }

    class ConnectionTestPlugin: Plugin {
        var receivedInt: Int?
        var receivedStruct: TestStruct?
        var connection: Connection?

        func bind<C>(to connection: C) where C: Connection {
            self.connection = connection
            connection.bind(anInt, as: "anInt")
            connection.bind(arrayOfInts, as: "arrayOfInts")
            connection.bind(aStruct, as: "aStruct")
            connection.bind(intParameter, as: "intParameter")
            connection.bind(structParameter, as: "structParameter")
            connection.bind(callbackParameter, as: "callbackParameter")
            connection.bind(callCallbackStructParameter, as: "callCallbackStructParameter")
            connection.bind(callbackEncodableParameter, as: "callbackEncodableParameter")
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

        func callbackParameter(number: Int, completion: (Int) -> Void) {
            receivedInt = number
            completion(number + 1)
        }

        func callbackEncodableParameter(callback: (Encodable) -> Void) {
            callback(TestStruct(foo: "structparam", bar: 15))
        }

        func callCallbackStructParameter(number: Int, completion: (TestStruct) -> Void) {
            receivedInt = number
            let thing = TestStruct(foo: "structparam", bar: 15)
            completion(thing)
        }

        func callWith(first: Int, second: Int, callback: @escaping ([Int]) -> Void) {
            guard let connection = connection else {
                XCTFail("nil connection")
                return
            }

            connection.evaluate("testFunctionWithArgs", with: [first, second]) { (_, result: [Int]?) in
                callback(result!)
            }
        }

        func callStruct(foo: String, bar: Int, callback: @escaping (TestStruct) -> Void) {
            guard let connection = connection else {
                XCTFail("nil connection")
                return
            }
            connection.evaluate("testStruct", with: [foo, bar]) { (_, result: TestStruct?) in
                callback(result!)
            }
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
        beginPluginTest()
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
        beginPluginTest()
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
        beginPluginTest()
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
        beginPluginTest()
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
        beginPluginTest()
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

    func testCallbackParameter() throws {
        beginPluginTest()
        let testScript = """
        function checkResult() {

        }
        function callbackResult(result) {
            if (result !== 4) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
            return;
        }
        __nimbus.plugins.ConnectionTestPlugin.callbackParameter(3, callbackResult).then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 3)
        XCTAssertTrue(expectationPlugin.passed)
        XCTAssertEqual(testPlugin.receivedInt, 3)
    }

    func testCallbackStructParameter() throws {
        beginPluginTest()
        let testScript = """
        function checkResult() {}
        function callbackResult(result) {
            if (result.foo !== "structparam") {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            if (result.bar !== 15) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
            return;
        }
        __nimbus.plugins.ConnectionTestPlugin.callCallbackStructParameter(3, callbackResult).then(checkResult);
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 3)
        XCTAssertTrue(expectationPlugin.passed)
        XCTAssertEqual(testPlugin.receivedInt, 3)
    }

    func testCallbackEncodable() throws {
        beginPluginTest()
        let testScript = """
        function callbackResult(result) {
            if (result.foo !== "structparam") {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            if (result.bar !== 15) {
                __nimbus.plugins.ExpectationPlugin.fail();
                return;
            }
            __nimbus.plugins.ExpectationPlugin.pass();
            return;
        }
        __nimbus.plugins.ConnectionTestPlugin.callbackEncodableParameter(callbackResult).then();
        """
        _ = context.evaluateScript(testScript)
        wait(for: expectationPlugin.currentExpectations(), timeout: 3)
        XCTAssertTrue(expectationPlugin.passed)
    }

    func testJSValueFunctionExtension() {
        let numberScript = "5"
        let numberResult = context.evaluateScript(numberScript)
        let objectScript = "{ \"foo\": \"bar\" }"
        let objectResult = context.evaluateScript(objectScript)
        let arrayScript = "[1, 2, 3]"
        let arrayResult = context.evaluateScript(arrayScript)
        let functionScript = """
        function myThing() {
            console.log("hello");
        }
        myThing;
        """
        let functionResult = context.evaluateScript(functionScript)

        XCTAssertEqual(numberResult?.isFunction(), false)
        XCTAssertEqual(objectResult?.isFunction(), false)
        XCTAssertEqual(arrayResult?.isFunction(), false)
        XCTAssertEqual(functionResult?.isFunction(), true)
    }

    func testCallJSWithParams() throws {
        bridge.attach(to: context)
        let expect = expectation(description: "call js")
        let fixtureScript = """
        function testFunctionWithArgs(...args) {
          return Array.prototype.slice.apply(args);
        };
        """
        context.evaluateScript(fixtureScript)
        testPlugin.callWith(first: 41, second: 42) { result in
            XCTAssertEqual(result[0], 41)
            XCTAssertEqual(result[1], 42)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }

    func testCallJSWithStruct() throws {
        bridge.attach(to: context)
        let expect = expectation(description: "call js")
        let fixtureScript = """
        function testStruct(foo, bar) {
          return { "foo": foo, "bar": bar };
        };
        """
        context.evaluateScript(fixtureScript)
        testPlugin.callStruct(foo: "blah", bar: 15) { result in
            XCTAssertEqual(result.foo, "blah")
            XCTAssertEqual(result.bar, 15)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }
}

class ExpectationPlugin: Plugin {
    var currentExpectation: XCTestExpectation?
    var passed = false

    func bind<C>(to connection: C) where C: Connection {
        connection.bind(fail, as: "fail")
        connection.bind(pass, as: "pass")
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
