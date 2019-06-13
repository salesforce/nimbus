//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest

@testable import Nimbus

// repetitive tests are repetitive...
// swiftlint:disable type_body_length file_length

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

    func testBindUnaryWithReturn() {
        binder.bind(BindTarget.unaryWithReturn, as: "")
        let value = try? binder.callable?.call(args: [42]) as? Int
        XCTAssert(binder.target.called)
        XCTAssertEqual(value, .some(42))
    }

    func testBindUnaryWithReturnThrows() {
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
        var result: Int?
        let callback: BindTarget.UnaryCallback = { value in
            result = value
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
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

    func testBindQuaternaryWithBinaryCallbackThrows() {
        binder.bind(BindTarget.quaternaryWithBinaryCallbackThrows, as: "")
        let expecter = expectation(description: "callback")
        var result: Int?
        let callback: BindTarget.BinaryCallback = { value1, value2 in
            result = value1 + value2
            expecter.fulfill()
        }
        XCTAssertThrowsError(try binder.callable?.call(args: [42, 37, 13, make_callable(callback)]))
        wait(for: [expecter], timeout: 5)
        XCTAssert(binder.target.called)
        XCTAssertEqual(result, .some(92))
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
