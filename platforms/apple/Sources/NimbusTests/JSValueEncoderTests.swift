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
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    struct TestEncodable: Encodable {
        let foo: Int
        let bar: String
    }

    func testBasicStruct() throws {
        let testValue = TestEncodable(foo: 2, bar: "baz")
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
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

}
