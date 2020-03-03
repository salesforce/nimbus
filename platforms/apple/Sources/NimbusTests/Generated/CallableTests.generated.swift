// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//
// swiftlint:disable line_length vertical_whitespace

import XCTest

@testable import Nimbus

class CallableTests: XCTestCase {
    let testable = Testable()

    func testNullaryCallable() {
        let callable = make_callable(Testable.nullary(testable))
        let result = try? callable.call(args: []) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 0)
    }

    func testNullaryArgCountFails() {
        let callable = make_callable(Testable.nullary(testable))
        XCTAssertThrowsError(try callable.call(args: [1]))
    }
    func testUnaryCallable() {
        let callable = make_callable(Testable.unary(testable))
        let result = try? callable.call(args: [1]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 1)
    }

    func testUnaryArgCountFails() {
        let callable = make_callable(Testable.unary(testable))
        XCTAssertThrowsError(try callable.call(args: [1, 2]))
    }
    func testBinaryCallable() {
        let callable = make_callable(Testable.binary(testable))
        let result = try? callable.call(args: [1, 2]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 2)
    }

    func testBinaryArgCountFails() {
        let callable = make_callable(Testable.binary(testable))
        XCTAssertThrowsError(try callable.call(args: [1, 2, 3]))
    }
    func testTernaryCallable() {
        let callable = make_callable(Testable.ternary(testable))
        let result = try? callable.call(args: [1, 2, 3]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 3)
    }

    func testTernaryArgCountFails() {
        let callable = make_callable(Testable.ternary(testable))
        XCTAssertThrowsError(try callable.call(args: [1, 2, 3, 4]))
    }
    func testQuaternaryCallable() {
        let callable = make_callable(Testable.quaternary(testable))
        let result = try? callable.call(args: [1, 2, 3, 4]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 4)
    }

    func testQuaternaryArgCountFails() {
        let callable = make_callable(Testable.quaternary(testable))
        XCTAssertThrowsError(try callable.call(args: [1, 2, 3, 4, 5]))
    }
    func testQuinaryCallable() {
        let callable = make_callable(Testable.quinary(testable))
        let result = try? callable.call(args: [1, 2, 3, 4, 5]) as? Int
        XCTAssertTrue(testable.called)
        XCTAssertEqual(result, 5)
    }

    func testQuinaryArgCountFails() {
        let callable = make_callable(Testable.quinary(testable))
        XCTAssertThrowsError(try callable.call(args: [1, 2, 3, 4, 5, 6]))
    }

    func testNullaryDecodable() {
        let callable = make_callable(Testable.nullaryDecodable(testable))
        let result = try? callable.call(args: [])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {

            XCTAssertEqual(args.count, 0)
        } else {
            XCTFail("result wasn't an array")
        }
    }

    func testUnaryDecodable() {
        let callable = make_callable(Testable.unaryDecodable(testable))
        let result = try? callable.call(args: [Testable.decodableJSON])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {
            for arg in args {
                XCTAssertEqual(arg.name, "TheName")
                XCTAssertEqual(arg.number, 42)
            }

        } else {
            XCTFail("result wasn't an array")
        }
    }

    func testBinaryDecodable() {
        let callable = make_callable(Testable.binaryDecodable(testable))
        let result = try? callable.call(args: [Testable.decodableJSON, Testable.decodableJSON])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {
            for arg in args {
                XCTAssertEqual(arg.name, "TheName")
                XCTAssertEqual(arg.number, 42)
            }

        } else {
            XCTFail("result wasn't an array")
        }
    }

    func testTernaryDecodable() {
        let callable = make_callable(Testable.ternaryDecodable(testable))
        let result = try? callable.call(args: [Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {
            for arg in args {
                XCTAssertEqual(arg.name, "TheName")
                XCTAssertEqual(arg.number, 42)
            }

        } else {
            XCTFail("result wasn't an array")
        }
    }

    func testQuaternaryDecodable() {
        let callable = make_callable(Testable.quaternaryDecodable(testable))
        let result = try? callable.call(args: [Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {
            for arg in args {
                XCTAssertEqual(arg.name, "TheName")
                XCTAssertEqual(arg.number, 42)
            }

        } else {
            XCTFail("result wasn't an array")
        }
    }

    func testQuinaryDecodable() {
        let callable = make_callable(Testable.quinaryDecodable(testable))
        let result = try? callable.call(args: [Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON, Testable.decodableJSON])
        let arrayResult = result as? [Testable.TestableDecodableStruct]
        XCTAssertNotNil(arrayResult)
        XCTAssertTrue(testable.called)
        if let args = arrayResult {
            for arg in args {
                XCTAssertEqual(arg.name, "TheName")
                XCTAssertEqual(arg.number, 42)
            }

        } else {
            XCTFail("result wasn't an array")
        }
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

    static let decodableJSON = """
        {
            "name": "TheName",
            "number": 42
        }
    """

    struct TestableDecodableStruct: Decodable {
        let name: String
        let number: Int
    }

    private(set) var called = false

    func nullary() -> Int {
        called = true
        return 0
    }

    func unary(arg0: Int) -> Int {
        called = true
        return 1
    }

    func binary(arg0: Int, arg1: Int) -> Int {
        called = true
        return 2
    }

    func ternary(arg0: Int, arg1: Int, arg2: Int) -> Int {
        called = true
        return 3
    }

    func quaternary(arg0: Int, arg1: Int, arg2: Int, arg3: Int) -> Int {
        called = true
        return 4
    }

    func quinary(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int) -> Int {
        called = true
        return 5
    }


    func nullaryDecodable() -> [TestableDecodableStruct] {
        called = true
        return []
    }

    func unaryDecodable(arg0: TestableDecodableStruct) -> [TestableDecodableStruct] {
        called = true
        return [arg0]
    }

    func binaryDecodable(arg0: TestableDecodableStruct, arg1: TestableDecodableStruct) -> [TestableDecodableStruct] {
        called = true
        return [arg0, arg1]
    }

    func ternaryDecodable(arg0: TestableDecodableStruct, arg1: TestableDecodableStruct, arg2: TestableDecodableStruct) -> [TestableDecodableStruct] {
        called = true
        return [arg0, arg1, arg2]
    }

    func quaternaryDecodable(arg0: TestableDecodableStruct, arg1: TestableDecodableStruct, arg2: TestableDecodableStruct, arg3: TestableDecodableStruct) -> [TestableDecodableStruct] {
        called = true
        return [arg0, arg1, arg2, arg3]
    }

    func quinaryDecodable(arg0: TestableDecodableStruct, arg1: TestableDecodableStruct, arg2: TestableDecodableStruct, arg3: TestableDecodableStruct, arg4: TestableDecodableStruct) -> [TestableDecodableStruct] {
        called = true
        return [arg0, arg1, arg2, arg3, arg4]
    }


    func callbackable(arg0: Int, arg1: (Int) -> Void) {
        arg1(arg0)
    }
}
