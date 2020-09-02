//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest
@testable import Nimbus

class TestPlugin: Plugin {
    var eventPublisher = EventPublisher<SharedTestEvents>()

    var namespace: String {
        return "testPlugin"
    }

    func publishStructEvent() {
        eventPublisher.publishEvent(\SharedTestEvents.structEvent, payload: StructEvent(theStruct: TestStruct()))
    }

    func bind<C>(to connection: C) where C: Connection { // swiftlint:disable:this function_body_length
        eventPublisher.bind(to: connection)
        connection.bind(nullaryResolvingToInt, as: "nullaryResolvingToInt")
        connection.bind(nullaryResolvingToDouble, as: "nullaryResolvingToDouble")
        connection.bind(nullaryResolvingToString, as: "nullaryResolvingToString")
        connection.bind(nullaryResolvingToStruct, as: "nullaryResolvingToStruct")
        connection.bind(nullaryResolvingToIntList, as: "nullaryResolvingToIntList")
        connection.bind(nullaryResolvingToDoubleList, as: "nullaryResolvingToDoubleList")
        connection.bind(nullaryResolvingToStringList, as: "nullaryResolvingToStringList")
        connection.bind(nullaryResolvingToStructList, as: "nullaryResolvingToStructList")
        connection.bind(nullaryResolvingToIntArray, as: "nullaryResolvingToIntArray")
        connection.bind(nullaryResolvingToStringStringMap, as: "nullaryResolvingToStringStringMap")
        connection.bind(nullaryResolvingToStringIntMap, as: "nullaryResolvingToStringIntMap")
        connection.bind(nullaryResolvingToStringDoubleMap, as: "nullaryResolvingToStringDoubleMap")
        connection.bind(nullaryResolvingToStringStructMap, as: "nullaryResolvingToStringStructMap")
        connection.bind(unaryIntResolvingToInt, as: "unaryIntResolvingToInt")
        connection.bind(unaryDoubleResolvingToDouble, as: "unaryDoubleResolvingToDouble")
        connection.bind(unaryStringResolvingToInt, as: "unaryStringResolvingToInt")
        connection.bind(unaryStructResolvingToJsonString, as: "unaryStructResolvingToJsonString")
        connection.bind(unaryStringListResolvingToString, as: "unaryStringListResolvingToString")
        connection.bind(unaryIntListResolvingToString, as: "unaryIntListResolvingToString")
        connection.bind(unaryDoubleListResolvingToString, as: "unaryDoubleListResolvingToString")
        connection.bind(unaryStructListResolvingToString, as: "unaryStructListResolvingToString")
        connection.bind(unaryIntArrayResolvingToString, as: "unaryIntArrayResolvingToString")
        connection.bind(unaryStringStringMapResolvingToString, as: "unaryStringStringMapResolvingToString")
        connection.bind(unaryStringStructMapResolvingToString, as: "unaryStringStructMapResolvingToString")
        connection.bind(unaryCallbackEncodable, as: "unaryCallbackEncodable")
        connection.bind(nullaryResolvingToStringCallback, as: "nullaryResolvingToStringCallback")
        connection.bind(nullaryResolvingToIntCallback, as: "nullaryResolvingToIntCallback")
        connection.bind(nullaryResolvingToDoubleCallback, as: "nullaryResolvingToDoubleCallback")
        connection.bind(nullaryResolvingToStructCallback, as: "nullaryResolvingToStructCallback")
        connection.bind(nullaryResolvingToStringListCallback, as: "nullaryResolvingToStringListCallback")
        connection.bind(nullaryResolvingToIntListCallback, as: "nullaryResolvingToIntListCallback")
        connection.bind(nullaryResolvingToDoubleListCallback, as: "nullaryResolvingToDoubleListCallback")
        connection.bind(nullaryResolvingToStructListCallback, as: "nullaryResolvingToStructListCallback")
        connection.bind(nullaryResolvingToIntArrayCallback, as: "nullaryResolvingToIntArrayCallback")
        connection.bind(nullaryResolvingToStringStringMapCallback, as: "nullaryResolvingToStringStringMapCallback")
        connection.bind(nullaryResolvingToStringIntMapCallback, as: "nullaryResolvingToStringIntMapCallback")
        connection.bind(nullaryResolvingToStringDoubleMapCallback, as: "nullaryResolvingToStringDoubleMapCallback")
        connection.bind(nullaryResolvingToStringStructMapCallback, as: "nullaryResolvingToStringStructMapCallback")
        connection.bind(nullaryResolvingToStringIntCallback, as: "nullaryResolvingToStringIntCallback")
        connection.bind(nullaryResolvingToIntStructCallback, as: "nullaryResolvingToIntStructCallback")
        connection.bind(unaryIntResolvingToIntCallback, as: "unaryIntResolvingToIntCallback")
        connection.bind(binaryIntDoubleResolvingToIntDoubleCallback, as: "binaryIntDoubleResolvingToIntDoubleCallback")
        connection.bind(binaryIntResolvingIntCallbackReturnsInt, as: "binaryIntResolvingIntCallbackReturnsInt")
        connection.bind(nullaryResolvingToSimpleError, as: "nullaryResolvingToSimpleError")
        connection.bind(nullaryResolvingToStructuredError, as: "nullaryResolvingToStructuredError")
        connection.bind(takesString, as: "takesString")
        connection.bind(takesNumber, as: "takesNumber")
        connection.bind(takesBool, as: "takesBool")
        connection.bind(takesDictionary, as: "takesDictionary")
        connection.bind(takesTestStruct, as: "takesTestStruct")
    }

    func takesString(stringParam: String) -> String { return stringParam }
    func takesNumber(numberParam: Double) {}
    func takesBool(boolParam: Bool) {}
    func takesDictionary(dictionaryParam: [String: String]) {}
    func takesTestStruct(testStructParam: TestStruct) {}

    func nullaryResolvingToInt() -> Int {
        return 5
    }

    func nullaryResolvingToDouble() -> Double {
        return 10.0
    }

    func nullaryResolvingToString() -> String {
        return "aString"
    }

    func nullaryResolvingToStruct() -> TestStruct {
        return TestStruct()
    }

    func nullaryResolvingToIntList() -> [Int] {
        return [1, 2, 3]
    }

    func nullaryResolvingToDoubleList() -> [Double] {
        return [4.0, 5.0, 6.0]
    }

    func nullaryResolvingToStringList() -> [String] {
        return ["1", "2", "3"]
    }

    func nullaryResolvingToStructList() -> [TestStruct] {
        return [
            TestStruct("1", 1, 1.0),
            TestStruct("2", 2, 2.0),
            TestStruct("3", 3, 3.0),
        ]
    }

    func nullaryResolvingToIntArray() -> [Int] {
        return [1, 2, 3]
    }

    func nullaryResolvingToStringStringMap() -> [String: String] {
        return ["key1": "value1", "key2": "value2", "key3": "value3"]
    }

    func nullaryResolvingToStringIntMap() -> [String: Int] {
        return ["key1": 1, "key2": 2, "key3": 3]
    }

    func nullaryResolvingToStringDoubleMap() -> [String: Double] {
        return ["key1": 1.0, "key2": 2.0, "key3": 3.0]
    }

    func nullaryResolvingToStringStructMap() -> [String: TestStruct] {
        return [
            "key1": TestStruct("1", 1, 1.0),
            "key2": TestStruct("2", 2, 2.0),
            "key3": TestStruct("3", 3, 3.0),
        ]
    }

    func unaryIntResolvingToInt(param: Int) -> Int {
        return param + 1
    }

    func unaryDoubleResolvingToDouble(param: Double) -> Double {
        return param * 2
    }

    func unaryStringResolvingToInt(param: String) -> Int {
        return param.count
    }

    func unaryStructResolvingToJsonString(param: TestStruct) -> String {
        return param.asJSONString()
    }

    func unaryStringListResolvingToString(param: [String]) -> String {
        return param.joined(separator: ", ")
    }

    func unaryIntListResolvingToString(param: [Int]) -> String {
        return param.map { String($0) }.joined(separator: ", ")
    }

    func unaryDoubleListResolvingToString(param: [Double]) -> String {
        return param.map { String($0) }.joined(separator: ", ")
    }

    func unaryStructListResolvingToString(param: [TestStruct]) -> String {
        return param.map { $0.asString() }.joined(separator: ", ")
    }

    func unaryIntArrayResolvingToString(param: [Int]) -> String {
        return param.map { String($0) }.joined(separator: ", ")
    }

    func unaryStringStringMapResolvingToString(param: [String: String]) -> String {
        return param.map { "\($0.key), \($0.value)" }.sorted().joined(separator: ", ")
    }

    func unaryStringStructMapResolvingToString(param: [String: TestStruct]) -> String {
        return param.map { "\($0.key), \($0.value.asString())" }.sorted().joined(separator: ", ")
    }

    func unaryCallbackEncodable(callback: (Encodable) -> Void) {
        callback(TestStruct())
    }

    func nullaryResolvingToStringCallback(callback: (String) -> Void) {
        callback("param0")
    }

    func nullaryResolvingToIntCallback(callback: (Int) -> Void) {
        callback(1)
    }

    func nullaryResolvingToDoubleCallback(callback: (Double) -> Void) {
        callback(3.0)
    }

    func nullaryResolvingToStructCallback(callback: (TestStruct) -> Void) {
        callback(TestStruct())
    }

    func nullaryResolvingToStringListCallback(callback: ([String]) -> Void) {
        callback(["1", "2", "3"])
    }

    func nullaryResolvingToIntListCallback(callback: ([Int]) -> Void) {
        callback([1, 2, 3])
    }

    func nullaryResolvingToDoubleListCallback(callback: ([Double]) -> Void) {
        callback([1.0, 2.0, 3.0])
    }

    func nullaryResolvingToStructListCallback(callback: ([TestStruct]) -> Void) {
        callback(
            [
                TestStruct("1", 1, 1.0),
                TestStruct("2", 2, 2.0),
                TestStruct("3", 3, 3.0),
            ]
        )
    }

    func nullaryResolvingToIntArrayCallback(callback: ([Int]) -> Void) {
        callback([1, 2, 3])
    }

    func nullaryResolvingToStringStringMapCallback(callback: ([String: String]) -> Void) {
        callback(
            [
                "key1": "value1",
                "key2": "value2",
                "key3": "value3",
            ]
        )
    }

    func nullaryResolvingToStringIntMapCallback(callback: ([String: Int]) -> Void) {
        callback(
            [
                "1": 1,
                "2": 2,
                "3": 3,
            ]
        )
    }

    func nullaryResolvingToStringDoubleMapCallback(callback: ([String: Double]) -> Void) {
        callback(
            [
                "1.0": 1.0,
                "2.0": 2.0,
                "3.0": 3.0,
            ]
        )
    }

    func nullaryResolvingToStringStructMapCallback(callback: ([String: TestStruct]) -> Void) {
        callback(
            [
                "1": TestStruct("1", 1, 1.0),
                "2": TestStruct("2", 2, 2.0),
                "3": TestStruct("3", 3, 3.0),
            ]
        )
    }

    func nullaryResolvingToStringIntCallback(callback: (String, Int) -> Void) {
        callback("param0", 1)
    }

    func nullaryResolvingToIntStructCallback(callback: (Int, TestStruct) -> Void) {
        callback(2, TestStruct())
    }

    func unaryIntResolvingToIntCallback(param: Int, callback: (Int) -> Void) {
        callback(param + 1)
    }

    func binaryIntDoubleResolvingToIntDoubleCallback(param0: Int, param1: Double, callback: (Int, Double) -> Void) {
        callback(param0 + 1, param1 * 2)
    }

    func binaryIntResolvingIntCallbackReturnsInt(param0: Int, callback: (Int) -> Void) -> Int {
        callback(param0 - 1)
        return param0 - 2
    }

    func nullaryResolvingToSimpleError() throws -> String {
        throw TestSimpleError.simpleError
    }

    func nullaryResolvingToStructuredError() throws -> String {
        throw TestStructuredError()
    }
}

enum TestSimpleError: Error {
    case simpleError
}

struct TestStructuredError: Error, Encodable {
    let stringValue = "Structured error"
    let numberValue = 4.0
}

class ExpectPlugin: Plugin {
    var readyExpectation: XCTestExpectation?
    var finishedExpectation: XCTestExpectation?
    var isReady = false
    var isFinished = false
    var passed = false

    var namespace: String {
        return "expectPlugin"
    }

    func reset() {
        isFinished = false
        passed = false
        finishedExpectation = nil
    }

    func ready() {
        isReady = true
        readyExpectation?.fulfill()
    }

    func pass() {
        passed = true
    }

    func finished() {
        isFinished = true
        finishedExpectation?.fulfill()
    }

    func bind<C>(to connection: C) where C: Connection {
        connection.bind(ready, as: "ready")
        connection.bind(pass, as: "pass")
        connection.bind(finished, as: "finished")
    }
}

struct TestStruct: Codable {
    let string: String
    let integer: Int
    let double: Double

    init(_ string: String = "String", _ integer: Int = 1, _ double: Double = 2.0) {
        self.string = string
        self.integer = integer
        self.double = double
    }

    func asJSONString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        if let stringData = try? encoder.encode(self),
            let jsonString = String(data: stringData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }

    func asString() -> String {
        return "\(string), \(integer), \(double)"
    }
}

struct StructEvent: Codable {
    var theStruct: TestStruct
}

struct SharedTestEvents: EventKeyPathing {
    var structEvent: StructEvent

    static func stringForKeyPath(_ keyPath: PartialKeyPath<SharedTestEvents>) -> String? {
        switch keyPath {
        case \SharedTestEvents.structEvent: return "structEvent"
        default:
            return nil
        }
    }
}
