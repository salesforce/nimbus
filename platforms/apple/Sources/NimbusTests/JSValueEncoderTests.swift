//
//  JSValueEncoderTests.swift
//  NimbusTests
//
//  Created by Paul Tiarks on 4/9/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import XCTest
@testable import Nimbus
import JavaScriptCore

class JSValueEncoderTests: XCTestCase {
    var context: JSContext = JSContext()
    var encoder: JSValueEncoder = JSValueEncoder()

    override func setUpWithError() throws {
        context = JSContext()
        encoder = JSValueEncoder()
    }

    override func tearDownWithError() throws {
    }

    func executeAssertionScript(_ script: String, testValue: JSValue, key: String) -> Bool {
        context.setObject(testValue, forKeyedSubscript: key as NSString)
        let result = context.evaluateScript(script)
        if let result = result, result.isBoolean {
            return result.toBool()
        } else {
            return false
        }
    }

    func testInt() throws {
        let testValue: Int = 5
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isNumber)
        let assertScript = """
        function testValue() {
            if (valueToTest !== 5) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testString() throws {
        let testValue = "theteststring"
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isString)
        let assertScript = """
        function testValue() {
            if (valueToTest !== "\(testValue)") {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testArrayOfInts() throws {
        let testValue: [Int] = [1, 2, 5]
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isArray)
        let assertScript = """
        function testValue() {
            if (valueToTest.length !== \(testValue.count)) {
                return false
            }
            if (valueToTest[0] !== \(testValue[0])) {
                return false
            }
            if (valueToTest[1] !== \(testValue[1])) {
                return false
            }
            if (valueToTest[2] !== \(testValue[2])) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    struct TestEncodable: Encodable {
        let foo: Int
        let bar: String
        let thing: [Int]
    }

    func testBasicStruct() throws {
        let testValue = TestEncodable(foo: 2, bar: "baz", thing: [1, 2])
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isObject)
        let assertScript = """
        function testValue() {
            if (valueToTest.foo !== \(testValue.foo)) {
                return false
            }
            if (valueToTest.bar !== "\(testValue.bar)") {
                return false
            }
            if (valueToTest.thing[0] !== \(testValue.thing[0])) {
                return false
            }
            if (valueToTest.thing[1] !== \(testValue.thing[1])) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    struct TestEncodableNested: Encodable {
        let foo: Int
        let bar: String
        let nest: TestEncodable
    }

    func testBasicStructNested() throws {
        let nest = TestEncodable(foo: 2, bar: "baz", thing: [1, 2])
        let testValue = TestEncodableNested(foo: 19, bar: "baz", nest: nest)
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isObject)
        let assertScript = """
        function testValue() {
            if (valueToTest.foo !== \(testValue.foo)) {
                return false
            }
            if (valueToTest.bar !== "\(testValue.bar)") {
                return false
            }
            if (valueToTest.nest.foo !== \(testValue.nest.foo)) {
                return false
            }
            if (valueToTest.nest.bar !== "\(testValue.nest.bar)") {
                return false
            }
            if (valueToTest.nest.thing[0] !== \(testValue.nest.thing[0])) {
                return false
            }
            if (valueToTest.nest.thing[1] !== \(testValue.nest.thing[1])) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

}
