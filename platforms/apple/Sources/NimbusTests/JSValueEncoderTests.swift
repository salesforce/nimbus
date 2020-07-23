//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable type_body_length file_length

import JavaScriptCore
import XCTest
@testable import Nimbus

class JSValueEncoderTests: XCTestCase {
    var context: JSContext = JSContext()
    var encoder: JSValueEncoder = JSValueEncoder()

    override func setUp() {
        context = JSContext()
        encoder = JSValueEncoder()
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

    func testJSValueExtensionAppend() {
        let array = JSValue(newArrayIn: context)
        array?.append(NSNumber(5))
        array?.append(NSNumber(6))
        array?.append(NSNumber(7))
        let assertScript = """
        function testValue() {
            if (valueToTest.length !== 3) {
                return false
            }
            if (valueToTest[0] !== 5) {
                return false
            }
            if (valueToTest[1] !== 6) {
                return false
            }
            if (valueToTest[2] !== 7) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: array!, key: "valueToTest"))
    }

    func testJSValueExtensionAppendObject() {
        let object = JSValue(newObjectIn: context)
        object?.append(NSNumber(5), for: "foo")
        object?.append("baz" as NSString, for: "bar")
        let assertScript = """
        function testValue() {
            if (valueToTest.foo !== 5) {
                return false
            }
            if (valueToTest.bar !== "baz") {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: object!, key: "valueToTest"))
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

    func testDouble() throws {
        let testValue: Double = 5.0
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isNumber)
        let assertScript = """
        function testValue() {
            if (valueToTest !== 5.0) {
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

    func testArrayOfArraysOfInts() throws {
        let testValue: [[Int]] = [[1, 2], [3, 4], [5, 6]]
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isArray)
        let assertScript = """
        function testValue() {
            if (valueToTest.length !== \(testValue.count)) {
                return false
            }
            if (valueToTest[0][0] !== \(testValue[0][0])) {
                return false
            }
            if (valueToTest[0][1] !== \(testValue[0][1])) {
                return false
            }

            if (valueToTest[1][0] !== \(testValue[1][0])) {
                return false
            }
            if (valueToTest[1][1] !== \(testValue[1][1])) {
                return false
            }

            if (valueToTest[2][0] !== \(testValue[2][0])) {
                return false
            }
            if (valueToTest[2][1] !== \(testValue[2][1])) {
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
        let double: Double
    }

    func testBasicStruct() throws {
        let testValue = TestEncodable(foo: 2, bar: "baz", thing: [1, 2], double: 3.0)
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
            if (valueToTest.double !== \(testValue.double)) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testArrayOfStructs() throws { // swiftlint:disable:this function_body_length
        let one = TestEncodable(foo: 1, bar: "blah", thing: [2], double: 2.0)
        let two = TestEncodable(foo: 2, bar: "blar", thing: [2], double: 3.0)
        let three = TestEncodable(foo: 3, bar: "blam", thing: [3], double: 4.0)
        let testValue = [one, two, three]
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isArray)
        let assertScript = """
        function testValue() {
            var one = valueToTest[0];
            var two = valueToTest[1];
            var three = valueToTest[2];
            if (valueToTest.length !== 3) {
                return false;
            }
            if (one.foo !== \(one.foo)) {
                return false;
            }
            if (one.bar !== "\(one.bar)") {
                return false;
            }
            if (one.thing[0] !== \(one.thing[0])) {
                return false;
            }
            if (one.double !== \(one.double)) {
                return false;
            }

            if (two.foo !== \(two.foo)) {
                return false;
            }
            if (two.bar !== "\(two.bar)") {
                return false;
            }
            if (two.thing[0] !== \(two.thing[0])) {
                return false;
            }
            if (two.double !== \(two.double)) {
                return false;
            }

            if (three.foo !== \(three.foo)) {
                return false;
            }
            if (three.bar !== "\(three.bar)") {
                return false;
            }
            if (three.thing[0] !== \(three.thing[0])) {
                return false;
            }
            if (three.double !== \(three.double)) {
                return false;
            }
            return true;
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
        let nest = TestEncodable(foo: 2, bar: "baz", thing: [1, 2], double: 3.0)
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
            if (valueToTest.nest.double !== \(testValue.nest.double)) {
                return false
            }
            return true
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testEncodableEnum() throws {
        let testEncodable = TestEncodable(foo: 4, bar: "bar", thing: [4], double: 4.0)
        let testValue = TestEncodableValue.value(testEncodable)
        let encoded = try encoder.encode(testValue, context: context)
        XCTAssertTrue(encoded.isObject)
        let assertScript = """
        function testValue() {
            if (valueToTest.value === undefined) {
                return false;
            }
            if (valueToTest.value.bar !== "bar") {
                return false;
            }
            return true;
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testKeyedContainerTypes() throws { // swiftlint:disable:this function_body_length
        let test = KeyedContainerTypesStruct()
        let encoded = try encoder.encode(test, context: context)
        XCTAssertTrue(encoded.isObject)
        let assertScript = """
        function testValue() {
            if (valueToTest.boolType !== true) {
                return false;
            }
            if (valueToTest.stringType !== "test") {
                return false;
            }
            if (valueToTest.doubleType !== 2.0) {
                return false;
            }
            if (valueToTest.floatType !== 3.0) {
                return false;
            }
            if (valueToTest.intType !== 4) {
                return false;
            }
            if (valueToTest.intEightType !== 5) {
                return false;
            }
            if (valueToTest.intSixteenType !== 6) {
                return false;
            }
            if (valueToTest.intThirtyTwoType !== 7) {
                return false;
            }
            if (valueToTest.intSixtyFourType !== 8) {
                return false;
            }
            if (valueToTest.uintType !== 9) {
                return false;
            }
            if (valueToTest.uintEightType !== 10) {
                return false;
            }
            if (valueToTest.uintSixteenType !== 11) {
                return false;
            }
            if (valueToTest.uintThirtyTwoType !== 12) {
                return false;
            }
            if (valueToTest.uintSixtyFourType !== 13) {
                return false;
            }
            return true;
        }
        testValue();
        """
        XCTAssertTrue(executeAssertionScript(assertScript, testValue: encoded, key: "valueToTest"))
    }

    func testUnkeyedContainerTypes() throws { // swiftlint:disable:this function_body_length
        let container = JSValueEncoderContainer(context: context)
        let storage = JSValue(newArrayIn: context)
        let unkeyed = JSValueUnkeyedEncodingContainer(
            encoder: container,
            container: storage,
            codingPath: []
        )
        XCTAssertEqual(storage?.length(), 0)
        try unkeyed.encode("test")
        XCTAssertEqual(storage?.length(), 1)
        XCTAssertEqual(storage?.atIndex(0)?.toString(), "test")

        try unkeyed.encode(2.2 as Double)
        XCTAssertEqual(storage?.length(), 2)
        XCTAssertEqual(storage!.atIndex(1)!.toDouble(), 2.2 as Double, accuracy: 0.01)

        try unkeyed.encode(3.3 as Float)
        XCTAssertEqual(storage?.length(), 3)
        XCTAssertEqual(storage!.atIndex(2)!.toDouble(), 3.3 as Double, accuracy: 0.01)

        try unkeyed.encode(4 as Int)
        XCTAssertEqual(storage?.length(), 4)
        XCTAssertEqual(storage?.atIndex(3)?.toInt32(), 4)

        try unkeyed.encode(5 as Int8)
        XCTAssertEqual(storage?.length(), 5)
        XCTAssertEqual(storage?.atIndex(4)?.toInt32(), 5)

        try unkeyed.encode(6 as Int16)
        XCTAssertEqual(storage?.length(), 6)
        XCTAssertEqual(storage?.atIndex(5)?.toInt32(), 6)

        try unkeyed.encode(7 as Int32)
        XCTAssertEqual(storage?.length(), 7)
        XCTAssertEqual(storage?.atIndex(6)?.toInt32(), 7)

        try unkeyed.encode(8 as Int64)
        XCTAssertEqual(storage?.length(), 8)
        XCTAssertEqual(storage?.atIndex(7)?.toInt32(), 8)

        try unkeyed.encode(9 as UInt)
        XCTAssertEqual(storage?.length(), 9)
        XCTAssertEqual(storage?.atIndex(8)?.toInt32(), 9)

        try unkeyed.encode(10 as UInt8)
        XCTAssertEqual(storage?.length(), 10)
        XCTAssertEqual(storage?.atIndex(9)?.toInt32(), 10)

        try unkeyed.encode(11 as UInt16)
        XCTAssertEqual(storage?.length(), 11)
        XCTAssertEqual(storage?.atIndex(10)?.toInt32(), 11)

        try unkeyed.encode(12 as UInt32)
        XCTAssertEqual(storage?.length(), 12)
        XCTAssertEqual(storage?.atIndex(11)?.toInt32(), 12)

        try unkeyed.encode(13 as UInt64)
        XCTAssertEqual(storage?.length(), 13)
        XCTAssertEqual(storage?.atIndex(12)?.toInt32(), 13)

        try unkeyed.encode(true)
        XCTAssertEqual(storage?.length(), 14)
        XCTAssertEqual(storage?.atIndex(13)?.toBool(), true)

        let testNil: String? = nil
        try unkeyed.encode(testNil)
        XCTAssertEqual(storage?.length(), 15)
        XCTAssertEqual(storage?.atIndex(14)?.isNull, true)
    }
}

extension JSValue {
    func length() -> Int32 {
        return objectForKeyedSubscript("length")?.toInt32() ?? 0 as Int32
    }
}

struct KeyedContainerTypesStruct: Encodable {
    let boolType = true
    let stringType = "test"
    let doubleType: Double = 2.0
    let floatType: Float = 3.0
    let intType: Int = 4
    let intEightType: Int8 = 5
    let intSixteenType: Int16 = 6
    let intThirtyTwoType: Int32 = 7
    let intSixtyFourType: Int64 = 8
    let uintType: UInt = 9
    let uintEightType: UInt8 = 10
    let uintSixteenType: UInt16 = 11
    let uintThirtyTwoType: UInt32 = 12
    let uintSixtyFourType: UInt64 = 13
}

enum TestEncodableValue: Encodable {
    case value(Encodable)

    enum Keys: String, CodingKey {
        case value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case let .value(encodableValue):
            let superContainer = container.superEncoder(forKey: .value)
            try encodableValue.encode(to: superContainer)
        }
    }
}
