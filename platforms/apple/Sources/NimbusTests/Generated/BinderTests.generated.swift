// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest

@testable import Nimbus

// repetitive tests are repetitive...
// swiftlint:disable type_body_length file_length line_length

class BinderTests: XCTestCase {
    let binder = TestBinder()

    func testBindNullaryNoReturn() {
        binder.bind(BindTarget.nullaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [])
        XCTAssert(binder.target.called)
    }

    func testBindNullaryNoReturnThrows() {
        binder.bind(BindTarget.nullaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: []))
        XCTAssert(binder.target.called)
    }

    func testBindNullaryWithReturn() {
        binder.bind(BindTarget.nullaryWithReturn, as: "")
        let value = try? binder.callable?.call(args: []) as? String
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some("value"))
    }

    func testBindNullaryWithNSArrayReturn() {
        binder.bind(BindTarget.nullaryWithNSArrayReturn, as: "")
        let value = try? binder.callable?.call(args: []) as? NSArray
        XCTAssert(binder.target.called)
        let isExpectedType = value is NSArray
        XCTAssertEqual(isExpectedType, true)
    }

    func testBindNullaryWithNSDictionaryReturn() {
        binder.bind(BindTarget.nullaryWithNSDictionaryReturn, as: "")
        let value = try? binder.callable?.call(args: []) as? NSDictionary
        XCTAssert(binder.target.called)
        let isExpectedType = value is NSDictionary
        XCTAssertEqual(isExpectedType, true)
    }

    func testBindNullaryWithReturnThrows() {
        binder.bind(BindTarget.nullaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: []))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryNoReturn() {
        binder.bind(BindTarget.unaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [42])
        XCTAssert(binder.target.called)
    }

    func testBindUnaryNoReturnThrows() {
        binder.bind(BindTarget.unaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42]))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithReturn() throws {
        binder.bind(BindTarget.unaryWithReturn, as: "")
        let value = try binder.callable?.call(args: [42]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(42))
    }

    func testBindUnaryWithNSArrayReturn() throws {
        binder.bind(BindTarget.unaryWithNSArrayReturn, as: "")
        let value = try binder.callable?.call(args: [42]) as? NSArray
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value.firstObject as? Int {
            XCTAssertEqual(result, 42)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindUnaryWithNSDictionaryReturn() throws {
        binder.bind(BindTarget.unaryWithNSDictionaryReturn, as: "")
        let value = try binder.callable?.call(args: [42]) as? NSDictionary
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value["result"] as? Int {
            XCTAssertEqual(result, 42)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindUnaryWithReturnThrows() throws {
        binder.bind(BindTarget.unaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42]))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithUnaryCallback() {
        binder.bind(BindTarget.unaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
    }

    func testBindUnaryWithUnaryCallbackThrows() {
        binder.bind(BindTarget.unaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithBinaryCallback() {
        binder.bind(BindTarget.unaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindUnaryWithBinaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindUnaryWithBinaryPrimitiveNSArrayCallback() {
        binder.bind(BindTarget.unaryWithBinaryPrimitiveNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryPrimitiveNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryPrimitiveNSDictionaryCallback() {
        binder.bind(BindTarget.unaryWithBinaryPrimitiveNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindUnaryWithBinaryPrimitiveNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindUnaryWithBinaryNSArrayPrimitiveCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSArrayPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryNSArrayPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryNSArrayNSArrayCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSArrayNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindUnaryWithBinaryNSArrayNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindUnaryWithBinaryNSArrayNSDictionaryCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSArrayNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindUnaryWithBinaryNSArrayNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindUnaryWithBinaryNSDictionaryPrimitiveCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindUnaryWithBinaryNSDictionaryPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindUnaryWithBinaryNSDictionaryNSArrayCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryNSDictionaryNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindUnaryWithBinaryNSDictionaryNSDictionaryCallback() {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindUnaryWithBinaryNSDictionaryNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.unaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 1)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindUnaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.unaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindBinaryNoReturn() {
        binder.bind(BindTarget.binaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [42, 37])
        XCTAssert(binder.target.called)
    }

    func testBindBinaryNoReturnThrows() {
        binder.bind(BindTarget.binaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37]))
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithReturn() throws {
        binder.bind(BindTarget.binaryWithReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(79))
    }

    func testBindBinaryWithNSArrayReturn() throws {
        binder.bind(BindTarget.binaryWithNSArrayReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37]) as? NSArray
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value.firstObject as? Int {
            XCTAssertEqual(result, 79)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindBinaryWithNSDictionaryReturn() throws {
        binder.bind(BindTarget.binaryWithNSDictionaryReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37]) as? NSDictionary
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value["result"] as? Int {
            XCTAssertEqual(result, 79)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindBinaryWithReturnThrows() throws {
        binder.bind(BindTarget.binaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37]))
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithUnaryCallback() {
        binder.bind(BindTarget.binaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
    }

    func testBindBinaryWithUnaryCallbackThrows() {
        binder.bind(BindTarget.binaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithBinaryCallback() {
        binder.bind(BindTarget.binaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindBinaryWithBinaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindBinaryWithBinaryPrimitiveNSArrayCallback() {
        binder.bind(BindTarget.binaryWithBinaryPrimitiveNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryPrimitiveNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryPrimitiveNSDictionaryCallback() {
        binder.bind(BindTarget.binaryWithBinaryPrimitiveNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindBinaryWithBinaryPrimitiveNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindBinaryWithBinaryNSArrayPrimitiveCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSArrayPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryNSArrayPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryNSArrayNSArrayCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSArrayNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindBinaryWithBinaryNSArrayNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindBinaryWithBinaryNSArrayNSDictionaryCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSArrayNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindBinaryWithBinaryNSArrayNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindBinaryWithBinaryNSDictionaryPrimitiveCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindBinaryWithBinaryNSDictionaryPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindBinaryWithBinaryNSDictionaryNSArrayCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryNSDictionaryNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindBinaryWithBinaryNSDictionaryNSDictionaryCallback() {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindBinaryWithBinaryNSDictionaryNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.binaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 2)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindBinaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.binaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindTernaryNoReturn() {
        binder.bind(BindTarget.ternaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [42, 37, 13])
        XCTAssert(binder.target.called)
    }

    func testBindTernaryNoReturnThrows() {
        binder.bind(BindTarget.ternaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13]))
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithReturn() throws {
        binder.bind(BindTarget.ternaryWithReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(92))
    }

    func testBindTernaryWithNSArrayReturn() throws {
        binder.bind(BindTarget.ternaryWithNSArrayReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13]) as? NSArray
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value.firstObject as? Int {
            XCTAssertEqual(result, 92)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindTernaryWithNSDictionaryReturn() throws {
        binder.bind(BindTarget.ternaryWithNSDictionaryReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13]) as? NSDictionary
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value["result"] as? Int {
            XCTAssertEqual(result, 92)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindTernaryWithReturnThrows() throws {
        binder.bind(BindTarget.ternaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13]))
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithUnaryCallback() {
        binder.bind(BindTarget.ternaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindTernaryWithUnaryCallbackThrows() {
        binder.bind(BindTarget.ternaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithBinaryCallback() {
        binder.bind(BindTarget.ternaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindTernaryWithBinaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindTernaryWithBinaryPrimitiveNSArrayCallback() {
        binder.bind(BindTarget.ternaryWithBinaryPrimitiveNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryPrimitiveNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryPrimitiveNSDictionaryCallback() {
        binder.bind(BindTarget.ternaryWithBinaryPrimitiveNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindTernaryWithBinaryPrimitiveNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindTernaryWithBinaryNSArrayPrimitiveCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryNSArrayPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryNSArrayNSArrayCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindTernaryWithBinaryNSArrayNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindTernaryWithBinaryNSArrayNSDictionaryCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindTernaryWithBinaryNSArrayNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindTernaryWithBinaryNSDictionaryPrimitiveCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindTernaryWithBinaryNSDictionaryPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindTernaryWithBinaryNSDictionaryNSArrayCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryNSDictionaryNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindTernaryWithBinaryNSDictionaryNSDictionaryCallback() {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindTernaryWithBinaryNSDictionaryNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.ternaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 3)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindTernaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.ternaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryNoReturn() {
        binder.bind(BindTarget.quaternaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [42, 37, 13, 7])
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryNoReturnThrows() {
        binder.bind(BindTarget.quaternaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7]))
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithReturn() throws {
        binder.bind(BindTarget.quaternaryWithReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(99))
    }

    func testBindQuaternaryWithNSArrayReturn() throws {
        binder.bind(BindTarget.quaternaryWithNSArrayReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7]) as? NSArray
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value.firstObject as? Int {
            XCTAssertEqual(result, 99)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindQuaternaryWithNSDictionaryReturn() throws {
        binder.bind(BindTarget.quaternaryWithNSDictionaryReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7]) as? NSDictionary
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value["result"] as? Int {
            XCTAssertEqual(result, 99)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindQuaternaryWithReturnThrows() throws {
        binder.bind(BindTarget.quaternaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7]))
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithUnaryCallback() {
        binder.bind(BindTarget.quaternaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
    }

    func testBindQuaternaryWithUnaryCallbackThrows() {
        binder.bind(BindTarget.quaternaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithBinaryCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
    }

    func testBindQuaternaryWithBinaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
    }

    func testBindQuaternaryWithBinaryPrimitiveNSArrayCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryPrimitiveNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryPrimitiveNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryPrimitiveNSDictionaryCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryPrimitiveNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuaternaryWithBinaryPrimitiveNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuaternaryWithBinaryNSArrayPrimitiveCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryNSArrayPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(37))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryNSArrayNSArrayCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindQuaternaryWithBinaryNSArrayNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindQuaternaryWithBinaryNSArrayNSDictionaryCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuaternaryWithBinaryNSArrayNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuaternaryWithBinaryNSDictionaryPrimitiveCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindQuaternaryWithBinaryNSDictionaryPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(37))
    }

    func testBindQuaternaryWithBinaryNSDictionaryNSArrayCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryNSDictionaryNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuaternaryWithBinaryNSDictionaryNSDictionaryCallback() {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindQuaternaryWithBinaryNSDictionaryNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quaternaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 4)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindQuaternaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.quaternaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryNoReturn() {
        binder.bind(BindTarget.quinaryNoReturn, as: "")
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, 1])
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryNoReturnThrows() {
        binder.bind(BindTarget.quinaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7, 1]))
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithReturn() throws {
        binder.bind(BindTarget.quinaryWithReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7, 1]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(100))
    }

    func testBindQuinaryWithNSArrayReturn() throws {
        binder.bind(BindTarget.quinaryWithNSArrayReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7, 1]) as? NSArray
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value.firstObject as? Int {
            XCTAssertEqual(result, 100)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindQuinaryWithNSDictionaryReturn() throws {
        binder.bind(BindTarget.quinaryWithNSDictionaryReturn, as: "")
        let value = try binder.callable?.call(args: [42, 37, 13, 7, 1]) as? NSDictionary
        XCTAssert(binder.target.called)
        if let value = value,
            let result = value["result"] as? Int {
            XCTAssertEqual(result, 100)
        } else {
            XCTFail("Value not found")
        }
    }

    func testBindQuinaryWithReturnThrows() throws {
        binder.bind(BindTarget.quinaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7, 1]))
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithUnaryCallback() {
        binder.bind(BindTarget.quinaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(99))
    }

    func testBindQuinaryWithUnaryCallbackThrows() {
        binder.bind(BindTarget.quinaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithBinaryCallback() {
        binder.bind(BindTarget.quinaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(99))
    }

    func testBindQuinaryWithBinaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(99))
    }

    func testBindQuinaryWithBinaryPrimitiveNSArrayCallback() {
        binder.bind(BindTarget.quinaryWithBinaryPrimitiveNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryPrimitiveNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryPrimitiveNSArrayCallback = { value1, value2 in
            result = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryPrimitiveNSDictionaryCallback() {
        binder.bind(BindTarget.quinaryWithBinaryPrimitiveNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuinaryWithBinaryPrimitiveNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryPrimitiveNSDictionaryCallback = { value1, value2 in
            result = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(55))
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuinaryWithBinaryNSArrayPrimitiveCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(44))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryNSArrayPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSArrayPrimitiveCallback = { value1, value2 in
            resultArray = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(44))
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryNSArrayNSArrayCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindQuinaryWithBinaryNSArrayNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray1: NSArray?
        var resultArray2: NSArray?
        let callback: BindTarget.BinaryNSArrayNSArrayCallback = { value1, value2 in
            resultArray1 = value1
            resultArray2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray1, ["one", "two", "three"])
        XCTAssertEqual(resultArray2, ["four", "five", "six"])
    }

    func testBindQuinaryWithBinaryNSArrayNSDictionaryCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuinaryWithBinaryNSArrayNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultArray: NSArray?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSArrayNSDictionaryCallback = { value1, value2 in
            resultArray = value1
            resultDict = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultArray, ["one", "two", "three"])
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
    }

    func testBindQuinaryWithBinaryNSDictionaryPrimitiveCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryPrimitiveCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(44))
    }

    func testBindQuinaryWithBinaryNSDictionaryPrimitiveCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        var resultDict: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryPrimitiveCallback = { value1, value2 in
            resultDict = value1
            result = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(result, .some(44))
    }

    func testBindQuinaryWithBinaryNSDictionaryNSArrayCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryNSArrayCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryNSDictionaryNSArrayCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict: NSDictionary?
        var resultArray: NSArray?
        let callback: BindTarget.BinaryNSDictionaryNSArrayCallback = { value1, value2 in
            resultDict = value1
            resultArray = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultArray, ["one", "two", "three"])
    }

    func testBindQuinaryWithBinaryNSDictionaryNSDictionaryCallback() {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryNSDictionaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        _ = try? binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindQuinaryWithBinaryNSDictionaryNSDictionaryCallbackReturnsPrimitive() throws {
        binder.bind(BindTarget.quinaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn, as: "")
        let expecter = expectation(description: "callback")
        var resultDict1: NSDictionary?
        var resultDict2: NSDictionary?
        let callback: BindTarget.BinaryNSDictionaryNSDictionaryCallback = { value1, value2 in
            resultDict1 = value1
            resultDict2 = value2
            expecter.fulfill()
        }
        if let value = try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]) as? Int {
            XCTAssertEqual(value, 5)
        } else {
            XCTFail("Expected a return value")
        }
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(resultDict1, ["one": 1, "two": 2, "three": 3])
        XCTAssertEqual(resultDict2, ["four": 4, "five": 5, "six": 6])
    }

    func testBindQuinaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.quinaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, 7, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }
}

enum BindError: Error {
    case boundMethodThrew
}

class BindTarget {
    private(set) var called = false

    typealias UnaryCallback = (Int) -> Void
    typealias BinaryCallback = (Int, Int) -> Void
    typealias UnaryNSArrayCallback = (NSArray) -> Void
    typealias UnaryNSDictionaryCallback = (NSDictionary) -> Void
    typealias BinaryPrimitiveNSArrayCallback = (Int, NSArray) -> Void
    typealias BinaryPrimitiveNSDictionaryCallback = (Int, NSDictionary) -> Void
    typealias BinaryNSArrayPrimitiveCallback = (NSArray, Int) -> Void
    typealias BinaryNSArrayNSArrayCallback = (NSArray, NSArray) -> Void
    typealias BinaryNSArrayNSDictionaryCallback = (NSArray, NSDictionary) -> Void
    typealias BinaryNSDictionaryPrimitiveCallback = (NSDictionary, Int) -> Void
    typealias BinaryNSDictionaryNSArrayCallback = (NSDictionary, NSArray) -> Void
    typealias BinaryNSDictionaryNSDictionaryCallback = (NSDictionary, NSDictionary) -> Void

    func nullaryNoReturn() {
        called = true
    }

    func nullaryNoReturnThrows() throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func nullaryWithReturn() -> String {
        called = true
        return "value"
    }

    func nullaryWithNSArrayReturn() -> NSArray {
        called = true
        return NSArray()
    }

    func nullaryWithNSDictionaryReturn() -> NSDictionary {
        called = true
        return NSDictionary()
    }

    func nullaryWithReturnThrows() throws -> String {
        called = true
        throw BindError.boundMethodThrew
    }

    func unaryNoReturn(arg0: Int) {
        called = true
    }

    func unaryNoReturnThrows(arg0: Int) throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func unaryWithReturn(arg0: Int) -> Int {
        called = true
        return arg0
    }

    func unaryWithReturnThrows(arg0: Int) throws -> Int {
        called = true
        throw BindError.boundMethodThrew
    }

    func unaryWithNSArrayReturn(arg0: Int) -> NSArray {
        called = true
        let arr: NSArray = [arg0]
        return arr
    }

    func unaryWithNSDictionaryReturn(arg0: Int) -> NSDictionary {
        called = true
        let dict: NSDictionary = ["result": arg0]
        return dict
    }

    func unaryWithUnaryCallback(callback: @escaping UnaryCallback) {
        called = true
        callback(42)
    }

    func unaryWithUnaryCallbackThrows(callback: @escaping UnaryCallback) throws {
        called = true
        callback(42)
        throw BindError.boundMethodThrew
    }

    func unaryWithUnaryNSArrayCallback(callback: @escaping UnaryNSArrayCallback) {
        called = true
        let arr: NSArray = ["one", "two", "three"]
        callback(arr)
    }

    func unaryWithUnaryNSDictionaryCallback(callback: @escaping UnaryNSDictionaryCallback) {
        called = true
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict)
    }

    func unaryWithBinaryCallback(callback: @escaping BinaryCallback) {
        called = true
        callback(42, 37)
    }

    func unaryWithBinaryCallbackWithPrimitiveReturn(callback: @escaping BinaryCallback) -> Int {
        called = true
        callback(42, 37)
        return 1
    }

    func unaryWithBinaryPrimitiveNSArrayCallback(callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(42, arr1)
    }

    func unaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn(callback: @escaping BinaryPrimitiveNSArrayCallback) -> Int {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(42, arr1)
        return 1
    }

    func unaryWithBinaryPrimitiveNSDictionaryCallback(callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(42, dict1)
    }

    func unaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn(callback: @escaping BinaryPrimitiveNSDictionaryCallback) -> Int {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(42, dict1)
        return 1
    }

    func unaryWithBinaryNSArrayPrimitiveCallback(callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
    }

    func unaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn(callback: @escaping BinaryNSArrayPrimitiveCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
        return 1
    }

    func unaryWithBinaryNSArrayNSArrayCallback(callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func unaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn(callback: @escaping BinaryNSArrayNSArrayCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
        return 1
    }

    func unaryWithBinaryNSArrayNSDictionaryCallback(callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func unaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn(callback: @escaping BinaryNSArrayNSDictionaryCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
        return 1
    }

    func unaryWithBinaryNSDictionaryPrimitiveCallback(callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
    }

    func unaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn(callback: @escaping BinaryNSDictionaryPrimitiveCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
        return 1
    }

    func unaryWithBinaryNSDictionaryNSArrayCallback(callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func unaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn(callback: @escaping BinaryNSDictionaryNSArrayCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
        return 1
    }

    func unaryWithBinaryNSDictionaryNSDictionaryCallback(callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
    }

    func unaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn(callback: @escaping BinaryNSDictionaryNSDictionaryCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
        return 1
    }

    func unaryWithBinaryCallbackThrows(callback: @escaping BinaryCallback) throws {
        called = true
        callback(42, 37)
        throw BindError.boundMethodThrew
    }

    func binaryNoReturn(arg0: Int, arg1: Int) {
        called = true
    }

    func binaryNoReturnThrows(arg0: Int, arg1: Int) throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func binaryWithReturn(arg0: Int, arg1: Int) -> Int {
        called = true
        return arg0 + arg1
    }

    func binaryWithReturnThrows(arg0: Int, arg1: Int) throws -> Int {
        called = true
        throw BindError.boundMethodThrew
    }

    func binaryWithNSArrayReturn(arg0: Int, arg1: Int) -> NSArray {
        called = true
        let arr: NSArray = [arg0 + arg1]
        return arr
    }

    func binaryWithNSDictionaryReturn(arg0: Int, arg1: Int) -> NSDictionary {
        called = true
        let dict: NSDictionary = ["result": arg0 + arg1]
        return dict
    }

    func binaryWithUnaryCallback(arg0: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0)
    }

    func binaryWithUnaryCallbackThrows(arg0: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0)
        throw BindError.boundMethodThrew
    }

    func binaryWithUnaryNSArrayCallback(callback: @escaping UnaryNSArrayCallback) {
        called = true
        let arr: NSArray = ["one", "two", "three"]
        callback(arr)
    }

    func binaryWithUnaryNSDictionaryCallback(callback: @escaping UnaryNSDictionaryCallback) {
        called = true
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict)
    }

    func binaryWithBinaryCallback(arg0: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0, 37)
    }

    func binaryWithBinaryCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryCallback) -> Int {
        called = true
        callback(arg0, 37)
        return 2
    }

    func binaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
    }

    func binaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) -> Int {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
        return 2
    }

    func binaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
    }

    func binaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) -> Int {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
        return 2
    }

    func binaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
    }

    func binaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
        return 2
    }

    func binaryWithBinaryNSArrayNSArrayCallback(arg0: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func binaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSArrayNSArrayCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
        return 2
    }

    func binaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func binaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
        return 2
    }

    func binaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
    }

    func binaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
        return 2
    }

    func binaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func binaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
        return 2
    }

    func binaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
    }

    func binaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
        return 2
    }

    func binaryWithBinaryCallbackThrows(arg0: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0, 37)
        throw BindError.boundMethodThrew
    }

    func ternaryNoReturn(arg0: Int, arg1: Int, arg2: Int) {
        called = true
    }

    func ternaryNoReturnThrows(arg0: Int, arg1: Int, arg2: Int) throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func ternaryWithReturn(arg0: Int, arg1: Int, arg2: Int) -> Int {
        called = true
        return arg0 + arg1 + arg2
    }

    func ternaryWithReturnThrows(arg0: Int, arg1: Int, arg2: Int) throws -> Int {
        called = true
        throw BindError.boundMethodThrew
    }

    func ternaryWithNSArrayReturn(arg0: Int, arg1: Int, arg2: Int) -> NSArray {
        called = true
        let arr: NSArray = [arg0 + arg1 + arg2]
        return arr
    }

    func ternaryWithNSDictionaryReturn(arg0: Int, arg1: Int, arg2: Int) -> NSDictionary {
        called = true
        let dict: NSDictionary = ["result": arg0 + arg1 + arg2]
        return dict
    }

    func ternaryWithUnaryCallback(arg0: Int, arg1: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1)
    }

    func ternaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1)
        throw BindError.boundMethodThrew
    }

    func ternaryWithUnaryNSArrayCallback(callback: @escaping UnaryNSArrayCallback) {
        called = true
        let arr: NSArray = ["one", "two", "three"]
        callback(arr)
    }

    func ternaryWithUnaryNSDictionaryCallback(callback: @escaping UnaryNSDictionaryCallback) {
        called = true
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict)
    }

    func ternaryWithBinaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0, arg1)
    }

    func ternaryWithBinaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryCallback) -> Int {
        called = true
        callback(arg0, arg1)
        return 3
    }

    func ternaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
    }

    func ternaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) -> Int {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
        return 3
    }

    func ternaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
    }

    func ternaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) -> Int {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
        return 3
    }

    func ternaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
    }

    func ternaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
        return 3
    }

    func ternaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func ternaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSArrayCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
        return 3
    }

    func ternaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func ternaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
        return 3
    }

    func ternaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
    }

    func ternaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
        return 3
    }

    func ternaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func ternaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
        return 3
    }

    func ternaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
    }

    func ternaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
        return 3
    }

    func ternaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0, arg1)
        throw BindError.boundMethodThrew
    }

    func quaternaryNoReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int) {
        called = true
    }

    func quaternaryNoReturnThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int) throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func quaternaryWithReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int) -> Int {
        called = true
        return arg0 + arg1 + arg2 + arg3
    }

    func quaternaryWithReturnThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int) throws -> Int {
        called = true
        throw BindError.boundMethodThrew
    }

    func quaternaryWithNSArrayReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int) -> NSArray {
        called = true
        let arr: NSArray = [arg0 + arg1 + arg2 + arg3]
        return arr
    }

    func quaternaryWithNSDictionaryReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int) -> NSDictionary {
        called = true
        let dict: NSDictionary = ["result": arg0 + arg1 + arg2 + arg3]
        return dict
    }

    func quaternaryWithUnaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1 + arg2)
    }

    func quaternaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1 + arg2)
        throw BindError.boundMethodThrew
    }

    func quaternaryWithUnaryNSArrayCallback(callback: @escaping UnaryNSArrayCallback) {
        called = true
        let arr: NSArray = ["one", "two", "three"]
        callback(arr)
    }

    func quaternaryWithUnaryNSDictionaryCallback(callback: @escaping UnaryNSDictionaryCallback) {
        called = true
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict)
    }

    func quaternaryWithBinaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0 + arg2, arg1)
    }

    func quaternaryWithBinaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryCallback) -> Int {
        called = true
        callback(arg0 + arg2, arg1)
        return 4
    }

    func quaternaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
    }

    func quaternaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) -> Int {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
        return 4
    }

    func quaternaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
    }

    func quaternaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) -> Int {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
        return 4
    }

    func quaternaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
    }

    func quaternaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
        return 4
    }

    func quaternaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func quaternaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSArrayCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
        return 4
    }

    func quaternaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func quaternaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
        return 4
    }

    func quaternaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
    }

    func quaternaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
        return 4
    }

    func quaternaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func quaternaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
        return 4
    }

    func quaternaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
    }

    func quaternaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
        return 4
    }

    func quaternaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0 + arg2, arg1)
        throw BindError.boundMethodThrew
    }

    func quinaryNoReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) {
        called = true
    }

    func quinaryNoReturnThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) throws {
        called = true
        throw BindError.boundMethodThrew
    }

    func quinaryWithReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) -> Int {
        called = true
        return arg0 + arg1 + arg2 + arg3 + arg4
    }

    func quinaryWithReturnThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) throws -> Int {
        called = true
        throw BindError.boundMethodThrew
    }

    func quinaryWithNSArrayReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) -> NSArray {
        called = true
        let arr: NSArray = [arg0 + arg1 + arg2 + arg3 + arg4]
        return arr
    }

    func quinaryWithNSDictionaryReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) -> NSDictionary {
        called = true
        let dict: NSDictionary = ["result": arg0 + arg1 + arg2 + arg3 + arg4]
        return dict
    }

    func quinaryWithUnaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1 + arg2 + arg3)
    }

    func quinaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1 + arg2 + arg3)
        throw BindError.boundMethodThrew
    }

    func quinaryWithUnaryNSArrayCallback(callback: @escaping UnaryNSArrayCallback) {
        called = true
        let arr: NSArray = ["one", "two", "three"]
        callback(arr)
    }

    func quinaryWithUnaryNSDictionaryCallback(callback: @escaping UnaryNSDictionaryCallback) {
        called = true
        let dict: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict)
    }

    func quinaryWithBinaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0 + arg2, arg1 + arg3)
    }

    func quinaryWithBinaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryCallback) -> Int {
        called = true
        callback(arg0 + arg2, arg1 + arg3)
        return 5
    }

    func quinaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
    }

    func quinaryWithBinaryPrimitiveNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) -> Int {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
        return 5
    }

    func quinaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
    }

    func quinaryWithBinaryPrimitiveNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) -> Int {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
        return 5
    }

    func quinaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1 + arg3)
    }

    func quinaryWithBinaryNSArrayPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1 + arg3)
        return 5
    }

    func quinaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func quinaryWithBinaryNSArrayNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSArrayCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
        return 5
    }

    func quinaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func quinaryWithBinaryNSArrayNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) -> Int {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
        return 5
    }

    func quinaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1 + arg3)
    }

    func quinaryWithBinaryNSDictionaryPrimitiveCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1 + arg3)
        return 5
    }

    func quinaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func quinaryWithBinaryNSDictionaryNSArrayCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
        return 5
    }

    func quinaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
    }

    func quinaryWithBinaryNSDictionaryNSDictionaryCallbackWithPrimitiveReturn(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) -> Int {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
        return 5
    }

    func quinaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0 + arg2, arg1 + arg3)
        throw BindError.boundMethodThrew
    }
}

class TestBinder: Binder {
    typealias Target = BindTarget
    let target = BindTarget()

    init() {}

    func bind(_ callable: Callable, as name: String) {
        self.callable = callable
    }

    public var callable: Callable?
}
