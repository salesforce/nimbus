//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest

@testable import Nimbus

class CallableTests: XCTestCase {
    let testable = Testable()

    func testNullaryCallback() {
        let callable = make_callable(Testable.nullary(testable))
        let result = try? callable.call(args: []) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 0)
    }

    func testUnaryCallable() {
        let callable = make_callable(Testable.unary(testable))
        let result = try? callable.call(args: [1]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 1)
    }

    func testBinaryCallable() {
        let callable = make_callable(Testable.binary(testable))
        let result = try? callable.call(args: [1, 2]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 2)
    }

    func testTernaryCallable() {
        let callable = make_callable(Testable.ternary(testable))
        let result = try? callable.call(args: [1, 2, 3]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 3)
    }

    func testQuaternaryCallable() {
        let callable = make_callable(Testable.quaternary(testable))
        let result = try? callable.call(args: [1, 2, 3, 4]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 4)
    }

    func testQuinaryCallable() {
        let callable = make_callable(Testable.quinary(testable))
        let result = try? callable.call(args: [1, 2, 3, 4, 5]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 5)
    }

    func testCallbackable() {
        let callable = make_callable(Testable.callbackable(testable))
        let expect = expectation(description: "called callback")

        let callback: (Int) -> Void = { (value: Int) in
            print("the int is \(value)")
            expect.fulfill()
        }
        _ = try? callable.call(args: [1, callback])
        wait(for: [expect], timeout: 5)
    }
}

class Testable {
    private(set) var called = false

    func nullary() -> Int {
        called = true
        return 0
    }

    func unary(arg0 _: Int) -> Int {
        called = true
        return 1
    }

    func binary(arg0 _: Int, arg1 _: Int) -> Int {
        called = true
        return 2
    }

    func ternary(arg0 _: Int, arg01 _: Int, arg2 _: Int) -> Int {
        called = true
        return 3
    }

    func quaternary(arg0 _: Int, arg1 _: Int, arg2 _: Int, arg3 _: Int) -> Int {
        called = true
        return 4
    }

    func quinary(arg0 _: Int, arg1 _: Int, arg2 _: Int, arg3 _: Int, arg4 _: Int) -> Int {
        called = true
        return 5
    }

    func callbackable(arg0: Int, arg1: (Int) -> Void) {
        arg1(arg0)
    }
}
