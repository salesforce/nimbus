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

    func unaryWithBinaryPrimitiveNSArrayCallback(callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(42, arr1)
    }

    func unaryWithBinaryPrimitiveNSDictionaryCallback(callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(42, dict1)
    }

    func unaryWithBinaryNSArrayPrimitiveCallback(callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
    }

    func unaryWithBinaryNSArrayNSArrayCallback(callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func unaryWithBinaryNSArrayNSDictionaryCallback(callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func unaryWithBinaryNSDictionaryPrimitiveCallback(callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
    }

    func unaryWithBinaryNSDictionaryNSArrayCallback(callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func unaryWithBinaryNSDictionaryNSDictionaryCallback(callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
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

    func binaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
    }

    func binaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
    }

    func binaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, 37)
    }

    func binaryWithBinaryNSArrayNSArrayCallback(arg0: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func binaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func binaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, 37)
    }

    func binaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func binaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
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

    func ternaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0, arr1)
    }

    func ternaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0, dict1)
    }

    func ternaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
    }

    func ternaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func ternaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func ternaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
    }

    func ternaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func ternaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
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

    func quaternaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
    }

    func quaternaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
    }

    func quaternaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1)
    }

    func quaternaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func quaternaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func quaternaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1)
    }

    func quaternaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func quaternaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
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

    func quinaryWithBinaryPrimitiveNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSArrayCallback) {
        called = true
        let arr1: NSArray = ["one", "two", "three"]
        callback(arg0 + arg2, arr1)
    }

    func quinaryWithBinaryPrimitiveNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryPrimitiveNSDictionaryCallback) {
        called = true
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arg0 + arg2, dict1)
    }

    func quinaryWithBinaryNSArrayPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayPrimitiveCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        callback(arr0, arg1 + arg3)
    }

    func quinaryWithBinaryNSArrayNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSArrayCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let arr1: NSArray = ["four", "five", "six"]
        callback(arr0, arr1)
    }

    func quinaryWithBinaryNSArrayNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSArrayNSDictionaryCallback) {
        called = true
        let arr0: NSArray = ["one", "two", "three"]
        let dict1: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(arr0, dict1)
    }

    func quinaryWithBinaryNSDictionaryPrimitiveCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryPrimitiveCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        callback(dict0, arg1 + arg3)
    }

    func quinaryWithBinaryNSDictionaryNSArrayCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSArrayCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let arr1: NSArray = ["one", "two", "three"]
        callback(dict0, arr1)
    }

    func quinaryWithBinaryNSDictionaryNSDictionaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryNSDictionaryNSDictionaryCallback) {
        called = true
        let dict0: NSDictionary = ["one": 1, "two": 2, "three": 3]
        let dict1: NSDictionary = ["four": 4, "five": 5, "six": 6]
        callback(dict0, dict1)
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
