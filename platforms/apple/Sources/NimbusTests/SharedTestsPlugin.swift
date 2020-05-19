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
    var namespace: String {
        return "testPlugin"
    }

    func bind<C>(to connection: C) where C: Connection { //swiftlint:disable:this function_body_length
        connection.bind(self.nullaryResolvingToInt, as: "nullaryResolvingToInt")
        connection.bind(self.nullaryResolvingToDouble, as: "nullaryResolvingToDouble")
        connection.bind(self.nullaryResolvingToString, as: "nullaryResolvingToString")
        connection.bind(self.nullaryResolvingToStruct, as: "nullaryResolvingToStruct")
        connection.bind(self.nullaryResolvingToIntList, as: "nullaryResolvingToIntList")
        connection.bind(self.nullaryResolvingToDoubleList, as: "nullaryResolvingToDoubleList")
        connection.bind(self.nullaryResolvingToStringList, as: "nullaryResolvingToStringList")
        connection.bind(self.nullaryResolvingToStructList, as: "nullaryResolvingToStructList")
        connection.bind(self.nullaryResolvingToIntArray, as: "nullaryResolvingToIntArray")
        connection.bind(self.nullaryResolvingToStringStringMap, as: "nullaryResolvingToStringStringMap")
        connection.bind(self.nullaryResolvingToStringIntMap, as: "nullaryResolvingToStringIntMap")
        connection.bind(self.nullaryResolvingToStringDoubleMap, as: "nullaryResolvingToStringDoubleMap")
        connection.bind(self.nullaryResolvingToStringStructMap, as: "nullaryResolvingToStringStructMap")
        connection.bind(self.unaryIntResolvingToInt, as: "unaryIntResolvingToInt")
        connection.bind(self.unaryDoubleResolvingToDouble, as: "unaryDoubleResolvingToDouble")
        connection.bind(self.unaryStringResolvingToInt, as: "unaryStringResolvingToInt")
        connection.bind(self.unaryStructResolvingToJsonString, as: "unaryStructResolvingToJsonString")
        connection.bind(self.unaryStringListResolvingToString, as: "unaryStringListResolvingToString")
        connection.bind(self.unaryIntListResolvingToString, as: "unaryIntListResolvingToString")
        connection.bind(self.unaryDoubleListResolvingToString, as: "unaryDoubleListResolvingToString")
        connection.bind(self.unaryStructListResolvingToString, as: "unaryStructListResolvingToString")
        connection.bind(self.unaryIntArrayResolvingToString, as: "unaryIntArrayResolvingToString")
        connection.bind(self.unaryStringStringMapResolvingToString, as: "unaryStringStringMapResolvingToString")
        connection.bind(self.unaryStringStructMapResolvingToString, as: "unaryStringStructMapResolvingToString")
        connection.bind(self.nullaryResolvingToStringCallback, as: "nullaryResolvingToStringCallback")
        connection.bind(self.nullaryResolvingToIntCallback, as: "nullaryResolvingToIntCallback")
        connection.bind(self.nullaryResolvingToDoubleCallback, as: "nullaryResolvingToDoubleCallback")
        connection.bind(self.nullaryResolvingToStructCallback, as: "nullaryResolvingToStructCallback")
        connection.bind(self.nullaryResolvingToStringListCallback, as: "nullaryResolvingToStringListCallback")
        connection.bind(self.nullaryResolvingToIntListCallback, as: "nullaryResolvingToIntListCallback")
        connection.bind(self.nullaryResolvingToDoubleListCallback, as: "nullaryResolvingToDoubleListCallback")
        connection.bind(self.nullaryResolvingToStructListCallback, as: "nullaryResolvingToStructListCallback")
        connection.bind(self.nullaryResolvingToIntArrayCallback, as: "nullaryResolvingToIntArrayCallback")
        connection.bind(self.nullaryResolvingToStringStringMapCallback, as: "nullaryResolvingToStringStringMapCallback")
        connection.bind(self.nullaryResolvingToStringIntMapCallback, as: "nullaryResolvingToStringIntMapCallback")
        connection.bind(self.nullaryResolvingToStringDoubleMapCallback, as: "nullaryResolvingToStringDoubleMapCallback")
        connection.bind(self.nullaryResolvingToStringStructMapCallback, as: "nullaryResolvingToStringStructMapCallback")
        connection.bind(self.nullaryResolvingToStringIntCallback, as: "nullaryResolvingToStringIntCallback")
        connection.bind(self.nullaryResolvingToIntStructCallback, as: "nullaryResolvingToIntStructCallback")
//        connection.bind(self.nullaryResolvingToIntDoubleStructCallback, as: "nullaryResolvingToIntDoubleStructCallback")
        connection.bind(self.unaryIntResolvingToIntCallback, as: "unaryIntResolvingToIntCallback")
        connection.bind(self.binaryIntDoubleResolvingToIntDoubleCallback, as: "binaryIntDoubleResolvingToIntDoubleCallback")
    }

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
            TestStruct("3", 3, 3.0)
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
            "key3": TestStruct("3", 3, 3.0)
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
        return param.asString()
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
        return param.map { "\($0.key), \($0.value)" }.joined(separator: ", ")
    }

    func unaryStringStructMapResolvingToString(param: [String: TestStruct]) -> String {
        return param.map { "\($0.key), \($0.value.asString())" }.joined(separator: ", ")
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
                TestStruct("3", 3, 3.0)
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
                "key3": "value3"
            ]
        )
    }

    func nullaryResolvingToStringIntMapCallback(callback: ([String: Int]) -> Void) {
        callback(
            [
                "1": 1,
                "2": 2,
                "3": 3
            ]
        )
    }

    func nullaryResolvingToStringDoubleMapCallback(callback: ([String: Double]) -> Void) {
        callback(
            [
                "1.0": 1.0,
                "2.0": 2.0,
                "3.0": 3.0
            ]
        )
    }

    func nullaryResolvingToStringStructMapCallback(callback: ([String: TestStruct]) -> Void) {
        callback(
            [
                "1": TestStruct("1", 1, 1.0),
                "2": TestStruct("2", 2, 2.0),
                "3": TestStruct("3", 3, 3.0)
            ]
        )
    }

    func nullaryResolvingToStringIntCallback(callback: (String, Int) -> Void) {
        callback("param0", 1)
    }

    func nullaryResolvingToIntStructCallback(callback: (Int, TestStruct) -> Void) {
        callback(2, TestStruct())
    }

    func nullaryResolvingToIntDoubleStructCallback(callback: (Int, Double, TestStruct) -> Void) {
        callback(3, 4.0, TestStruct())
    }

    func unaryIntResolvingToIntCallback(param: Int, callback: (Int) -> Void) {
        callback(param + 1)
    }

    func binaryIntDoubleResolvingToIntDoubleCallback(param0: Int, param1: Double, callback: (Int, Double) -> Void) {
        callback(param0 + 1, param1 * 2)
    }
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
        self.isFinished = false
        self.passed = false
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
        connection.bind(self.ready, as: "ready")
        connection.bind(self.pass, as: "pass")
        connection.bind(self.finished, as: "finished")
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

    func asString() -> String {
        if let stringData = try? JSONEncoder().encode(self),
            let jsonString = String(data: stringData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
}
