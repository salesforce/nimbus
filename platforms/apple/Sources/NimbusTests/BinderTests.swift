//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest

@testable import Nimbus

// repetitive tests are repetitive...
// swiftlint:disable type_body_length file_length identifier_name

class BinderTests: XCTestCase {
    let binder = TestBinder()

    func testTooFewArgsError() {
        binder.bind(binder.target.ternaryWithReturn, as: "")
        XCTAssertThrowsError(try binder.callable([1, 2])) { error in
            guard let paramError = error as? ParameterError else {
                return XCTFail("Expected argument count error, not \(error)")
            }
            XCTAssertEqual(paramError, .argumentCount(expected: 3, actual: 2))
        }
        XCTAssertFalse(binder.target.called)
    }

    func testTooManyArgsError() {
        binder.bind(binder.target.nullaryNoReturn, as: "")
        XCTAssertThrowsError(try binder.callable([1, 2, 3, 4, 5])) { error in
            guard let paramError = error as? ParameterError else {
                return XCTFail("Expected argument count error, not \(error)")
            }
            XCTAssertEqual(paramError, .argumentCount(expected: 0, actual: 5))
        }
        XCTAssertFalse(binder.target.called)
    }

    func testBindNullaryNoReturn() {
        binder.bind(binder.target.nullaryNoReturn, as: "")
        _ = try? binder.callable([])
        XCTAssert(binder.target.called)
    }

    func testBindNullaryNoReturnThrows() {
        binder.bind(binder.target.nullaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([]))
        XCTAssert(binder.target.called)
    }

    func testBindNullaryWithReturn() {
        binder.bind(binder.target.nullaryWithReturn, as: "")
        let value = try? binder.callable([]) as? String
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some("value"))
    }

    func testBindNullaryWithReturnThrows() {
        binder.bind(binder.target.nullaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([]))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryNoReturn() {
        binder.bind(binder.target.unaryNoReturn, as: "")
        _ = try? binder.callable([42])
        XCTAssert(binder.target.called)
    }

    func testBindUnaryNoReturnThrows() {
        binder.bind(binder.target.unaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42]))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithReturn() throws {
        binder.bind(binder.target.unaryWithReturn, as: "")
        let value = try binder.callable([42]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(42))
    }

    func testBindUnaryWithReturnThrows() throws {
        binder.bind(binder.target.unaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42]))
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithUnaryCallback() {
        binder.bind(binder.target.unaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable([callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
    }

    func testBindUnaryWithUnaryCallbackThrows() {
        binder.bind(binder.target.unaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindUnaryWithBinaryCallback() {
        binder.bind(binder.target.unaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable([callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindUnaryWithBinaryCallbackThrows() {
        binder.bind(binder.target.unaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindBinaryNoReturn() {
        binder.bind(binder.target.binaryNoReturn, as: "")
        _ = try? binder.callable([42, 37])
        XCTAssert(binder.target.called)
    }

    func testBindBinaryNoReturnThrows() {
        binder.bind(binder.target.binaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37]))
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithReturn() throws {
        binder.bind(binder.target.binaryWithReturn, as: "")
        let value = try binder.callable([42, 37]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(79))
    }

    func testBindBinaryWithReturnThrows() throws {
        binder.bind(binder.target.binaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37]))
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithUnaryCallback() {
        binder.bind(binder.target.binaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable([42, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(42))
    }

    func testBindBinaryWithUnaryCallbackThrows() {
        binder.bind(binder.target.binaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithBinaryCallback() {
        binder.bind(binder.target.binaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable([42, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindBinaryWithBinaryCallbackThrows() {
        binder.bind(binder.target.binaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindBinaryWithTwoUnaryCallback() {
        binder.bind(binder.target.binaryWithTwoUnaryCallback, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        _ = try? binder.callable([cb0, cb1])
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(37))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindBinaryWithTwoUnaryCallbackThrows() {
        binder.bind(binder.target.binaryWithTwoUnaryCallbackThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(37))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindBinaryWithTwoUnaryCallbackWithReturn() {
        binder.bind(binder.target.binaryWithTwoUnaryCallbackWithReturn, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        let value = try? binder.callable([cb0, cb1]) as? Int
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(37))
        XCTAssertEqual(result0, .some(37))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindBinaryWithTwoUnaryCallbackWithReturnThrows() {
        binder.bind(binder.target.binaryWithTwoUnaryCallbackWithReturnThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(37))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindTernaryNoReturn() {
        binder.bind(binder.target.ternaryNoReturn, as: "")
        _ = try? binder.callable([42, 37, 13])
        XCTAssert(binder.target.called)
    }

    func testBindTernaryNoReturnThrows() {
        binder.bind(binder.target.ternaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13]))
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithReturn() throws {
        binder.bind(binder.target.ternaryWithReturn, as: "")
        let value = try binder.callable([42, 37, 13]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(92))
    }

    func testBindTernaryWithReturnThrows() throws {
        binder.bind(binder.target.ternaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13]))
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithUnaryCallback() {
        binder.bind(binder.target.ternaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindTernaryWithUnaryCallbackThrows() {
        binder.bind(binder.target.ternaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithBinaryCallback() {
        binder.bind(binder.target.ternaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(79))
    }

    func testBindTernaryWithBinaryCallbackThrows() {
        binder.bind(binder.target.ternaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithTwoUnaryCallback() {
        binder.bind(binder.target.ternaryWithTwoUnaryCallback, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        _ = try? binder.callable([42, cb0, cb1])
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(42))
    }

    func testBindTernaryWithTwoUnaryCallbackThrows() {
        binder.bind(binder.target.ternaryWithTwoUnaryCallbackThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(42))
        XCTAssert(binder.target.called)
    }

    func testBindTernaryWithTwoUnaryCallbackWithReturn() {
        binder.bind(binder.target.ternaryWithTwoUnaryCallbackWithReturn, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        let value = try? binder.callable([42, cb0, cb1]) as? Int
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(42))
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(42))
    }

    func testBindTernaryWithTwoUnaryCallbackWithReturnThrows() {
        binder.bind(binder.target.ternaryWithTwoUnaryCallbackWithReturnThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(42))
    }

    func testBindQuaternaryNoReturnThrows() {
        binder.bind(binder.target.quaternaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7]))
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithReturn() throws {
        binder.bind(binder.target.quaternaryWithReturn, as: "")
        let value = try binder.callable([42, 37, 13, 7]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(99))
    }

    func testBindQuaternaryWithReturnThrows() throws {
        binder.bind(binder.target.quaternaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7]))
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithUnaryCallback() {
        binder.bind(binder.target.quaternaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, 13, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
    }

    func testBindQuaternaryWithUnaryCallbackThrows() {
        binder.bind(binder.target.quaternaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithBinaryCallback() {
        binder.bind(binder.target.quaternaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, 13, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
    }

    func testBindQuaternaryWithBinaryCallbackThrows() {
        binder.bind(binder.target.quaternaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithTwoUnaryCallback() {
        binder.bind(binder.target.quaternaryWithTwoUnaryCallback, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        _ = try? binder.callable([42, 37, cb0, cb1])
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindQuaternaryWithTwoUnaryCallbackThrows() {
        binder.bind(binder.target.quaternaryWithTwoUnaryCallbackThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(37))
        XCTAssert(binder.target.called)
    }

    func testBindQuaternaryWithTwoUnaryCallbackWithReturn() {
        binder.bind(binder.target.quaternaryWithTwoUnaryCallbackWithReturn, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        let value = try? binder.callable([42, 37, cb0, cb1]) as? Int
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(79))
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindQuaternaryWithTwoUnaryCallbackWithReturnThrows() {
        binder.bind(binder.target.quaternaryWithTwoUnaryCallbackWithReturnThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(42))
        XCTAssertEqual(result1, .some(37))
    }

    func testBindQuinaryNoReturn() {
        binder.bind(binder.target.quinaryNoReturn, as: "")
        _ = try? binder.callable([42, 37, 13, 7, 1])
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryNoReturnThrows() {
        binder.bind(binder.target.quinaryNoReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7, 1]))
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithReturn() throws {
        binder.bind(binder.target.quinaryWithReturn, as: "")
        let value = try binder.callable([42, 37, 13, 7, 1]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(100))
    }

    func testBindQuinaryWithReturnThrows() throws {
        binder.bind(binder.target.quinaryWithReturnThrows, as: "")
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7, 1]))
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithUnaryCallback() {
        binder.bind(binder.target.quinaryWithUnaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, 13, 7, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(99))
    }

    func testBindQuinaryWithUnaryCallbackThrows() {
        binder.bind(binder.target.quinaryWithUnaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.UnaryCallback = { value in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithBinaryCallback() {
        binder.bind(binder.target.quinaryWithBinaryCallback, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        _ = try? binder.callable([42, 37, 13, 7, callback])
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(99))
    }

    func testBindQuinaryWithBinaryCallbackThrows() {
        binder.bind(binder.target.quinaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, 7, callback]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithTwoUnaryCallback() {
        binder.bind(binder.target.quinaryWithTwoUnaryCallback, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        _ = try? binder.callable([42, 37, 13, cb0, cb1])
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(79))
        XCTAssertEqual(result1, .some(50))
    }

    func testBindQuinaryWithTwoUnaryCallbackThrows() {
        binder.bind(binder.target.quinaryWithTwoUnaryCallbackThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssertEqual(result0, .some(79))
        XCTAssertEqual(result1, .some(50))
        XCTAssert(binder.target.called)
    }

    func testBindQuinaryWithTwoUnaryCallbackWithReturn() {
        binder.bind(binder.target.quinaryWithTwoUnaryCallbackWithReturn, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        let value = try? binder.callable([42, 37, 13, cb0, cb1]) as? Int
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(92))
        XCTAssertEqual(result0, .some(79))
        XCTAssertEqual(result1, .some(50))
    }

    func testBindQuinaryWithTwoUnaryCallbackWithReturnThrows() {
        binder.bind(binder.target.quinaryWithTwoUnaryCallbackWithReturnThrows, as: "")
        let expecter0 = expectation(description: "cb0")
        let expecter1 = expectation(description: "cb1")
        var result0: Int?
        var result1: Int?
        let cb0: BindTarget.UnaryCallback = { value in
            result0 = value
            expecter0.fulfill()
        }
        let cb1: BindTarget.UnaryCallback = { value in
            result1 = value
            expecter1.fulfill()
        }
        XCTAssertThrowsError(try binder.callable([42, 37, 13, cb0, cb1]))
        wait(for: [expecter0, expecter1], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result0, .some(79))
        XCTAssertEqual(result1, .some(50))
    }
}

enum BindError: Error {
    case boundMethodThrew
}

class BindTarget {
    private(set) var called = false

    typealias UnaryCallback = (Int) -> Void
    typealias BinaryCallback = (Int, Int) -> Void

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

    func unaryWithUnaryCallback(callback: @escaping UnaryCallback) {
        called = true
        callback(42)
    }

    func unaryWithUnaryCallbackThrows(callback: @escaping UnaryCallback) throws {
        called = true
        callback(42)
        throw BindError.boundMethodThrew
    }

    func unaryWithBinaryCallback(callback: @escaping BinaryCallback) {
        called = true
        callback(42, 37)
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

    func binaryWithUnaryCallback(arg0: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0)
    }

    func binaryWithUnaryCallbackThrows(arg0: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0)
        throw BindError.boundMethodThrew
    }

    func binaryWithBinaryCallback(arg0: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0, 37)
    }

    func binaryWithBinaryCallbackThrows(arg0: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0, 37)
        throw BindError.boundMethodThrew
    }

    func binaryWithTwoUnaryCallback(callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) {
        called = true
        callback0(37)
        callback1(37)
    }

    func binaryWithTwoUnaryCallbackThrows(callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(37)
        callback1(37)
        throw BindError.boundMethodThrew
    }

    func binaryWithTwoUnaryCallbackWithReturn(callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) -> Int {
        called = true
        callback0(37)
        callback1(37)
        return 37
    }

    func binaryWithTwoUnaryCallbackWithReturnThrows(callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int {
        called = true
        callback0(37)
        callback1(37)
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

    func ternaryWithUnaryCallback(arg0: Int, arg1: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1)
    }

    func ternaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1)
        throw BindError.boundMethodThrew
    }

    func ternaryWithBinaryCallback(arg0: Int, arg1: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0, arg1)
    }

    func ternaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0, arg1)
        throw BindError.boundMethodThrew
    }

    func ternaryWithTwoUnaryCallback(arg0: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(arg0)
        callback1(arg0)
    }

    func ternaryWithTwoUnaryCallbackThrows(arg0: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(arg0)
        callback1(arg0)
        throw BindError.boundMethodThrew
    }

    func ternaryWithTwoUnaryCallbackWithReturn(arg0: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int {
        called = true
        callback0(arg0)
        callback1(arg0)
        return arg0
    }

    func ternaryWithTwoUnaryCallbackWithReturnThrows(arg0: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int { // swiftlint:disable:this line_length
        called = true
        callback0(arg0)
        callback1(arg0)
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

    func quaternaryWithUnaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1 + arg2)
    }

    func quaternaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1 + arg2)
        throw BindError.boundMethodThrew
    }

    func quaternaryWithBinaryCallback(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0 + arg2, arg1)
    }

    func quaternaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0 + arg2, arg1)
        throw BindError.boundMethodThrew
    }

    func quaternaryWithTwoUnaryCallback(arg0: Int, arg1: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(arg0)
        callback1(arg1)
    }

    func quaternaryWithTwoUnaryCallbackThrows(arg0: Int, arg1: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(arg0)
        callback1(arg1)
        throw BindError.boundMethodThrew
    }

    func quaternaryWithTwoUnaryCallbackWithReturn(arg0: Int, arg1: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int { // swiftlint:disable:this line_length
        called = true
        callback0(arg0)
        callback1(arg1)
        return arg0 + arg1
    }

    func quaternaryWithTwoUnaryCallbackWithReturnThrows(arg0: Int, arg1: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int { // swiftlint:disable:this line_length
        called = true
        callback0(arg0)
        callback1(arg1)
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

    func quinaryWithUnaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping UnaryCallback) {
        called = true
        callback(arg0 + arg1 + arg2 + arg3)
    }

    func quinaryWithUnaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping UnaryCallback) throws {
        called = true
        callback(arg0 + arg1 + arg2 + arg3)
        throw BindError.boundMethodThrew
    }

    func quinaryWithBinaryCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryCallback) {
        called = true
        callback(arg0 + arg2, arg1 + arg3)
    }

    func quinaryWithBinaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: @escaping BinaryCallback) throws {
        called = true
        callback(arg0 + arg2, arg1 + arg3)
        throw BindError.boundMethodThrew
    }

    func quinaryWithTwoUnaryCallback(arg0: Int, arg1: Int, arg2: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws {
        called = true
        callback0(arg0 + arg1)
        callback1(arg1 + arg2)
    }

    func quinaryWithTwoUnaryCallbackThrows(arg0: Int, arg1: Int, arg2: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws { // swiftlint:disable:this line_length
        called = true
        callback0(arg0 + arg1)
        callback1(arg1 + arg2)
        throw BindError.boundMethodThrew
    }

    func quinaryWithTwoUnaryCallbackWithReturn(arg0: Int, arg1: Int, arg2: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int { // swiftlint:disable:this line_length
        called = true
        callback0(arg0 + arg1)
        callback1(arg1 + arg2)
        return arg0 + arg1 + arg2
    }

    func quinaryWithTwoUnaryCallbackWithReturnThrows(arg0: Int, arg1: Int, arg2: Int, callback0: @escaping UnaryCallback, callback1: @escaping UnaryCallback) throws -> Int { // swiftlint:disable:this line_length
        called = true
        callback0(arg0 + arg1)
        callback1(arg1 + arg2)
        throw BindError.boundMethodThrew
    }
}

class TestBinder: CallableBinder {
    typealias Target = BindTarget
    let target = BindTarget()

    init() {}

    func bindCallable(_ name: String, to callable: @escaping Callable) {
        self.callable = callable
    }

    func decode<T: Decodable>(_ value: Any?, as type: T.Type) -> Result<T, Error> {
        switch value {
        case let result as T:
            return .success(result)
        default:
            return .failure(DecodeError())
        }
    }

    func encode<T: Encodable>(_ value: T) -> Result<Any?, Error> {
        return .success(value)
    }

    func callback<T: Encodable>(from value: Any?, taking argType: T.Type) -> Result<(T) -> Void, Error> {
        switch value {
        case let fn as (T) -> Void:
            return .success(fn)
        default:
            return .failure(DecodeError())
        }
    }

    func callback<T: Encodable, U: Encodable>(from value: Any?, taking argType: (T.Type, U.Type)) -> Result<(T, U) -> Void, Error> {
        switch value {
        case let fn as (T, U) -> Void:
            return .success(fn)
        default:
            return .failure(DecodeError())
        }
    }

    public var callable: Callable!
}
