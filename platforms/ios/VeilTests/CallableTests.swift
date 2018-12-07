/**
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


import XCTest

@testable import Veil

class CallableTests: XCTestCase {

    let testable = Testable()

    func testNullaryCallback() {
        let c = make_callable(Testable.nullary(testable))
        let r = try? c.call(args: []) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 0)
    }

    func testUnaryCallable() {
        let c = make_callable(Testable.unary(testable))
        let r = try? c.call(args: [1]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 1)
    }

    func testBinaryCallable() {
        let c = make_callable(Testable.binary(testable))
        let r = try? c.call(args: [1,2]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 2)
    }

    func testTernaryCallable() {
        let c = make_callable(Testable.ternary(testable))
        let r = try? c.call(args: [1,2,3]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 3)
    }

    func testQuaternaryCallable() {
        let c = make_callable(Testable.quaternary(testable))
        let r = try? c.call(args: [1,2,3,4]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 4)
    }

    func testQuinaryCallable() {
        let c = make_callable(Testable.quinary(testable))
        let r = try? c.call(args: [1,2,3,4,5]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(r, 5)
    }

    func testCallbackable() {
        let c = make_callable(Testable.callbackable(testable))
        let x = expectation(description: "called callback")

        let cb: (Int) -> () = { (i: Int) in
            print("the int is \(i)")
            x.fulfill()
        }
        let r = try? c.call(args: [1, cb])
        wait(for: [x], timeout: 5)
    }
}

class Testable {
    private(set) var called = false

    func nullary() -> Int {
        called = true
        return 0
    }

    func unary(a0: Int) -> Int {
        called = true
        return 1
    }

    func binary(a0: Int, a1: Int) -> Int {
        called = true
        return 2
    }

    func ternary(a0: Int, a1: Int, a2: Int) -> Int {
        called = true
        return 3
    }

    func quaternary(a0: Int, a1: Int, a2: Int, a3: Int) -> Int {
        called = true
        return 4
    }

    func quinary(a0: Int, a1: Int, a2: Int, a3: Int, a4: Int) -> Int {
        called = true
        return 5
    }

    func callbackable(a0: Int, a1: (Int) -> ()) {
        a1(a0)
    }
}
