//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore
import XCTest
@testable import Nimbus

class JSValueDecoderTests: XCTestCase {
    var context: JSContext!
    var decoder: JSValueDecoder!

    override func setUp() {
        context = JSContext()
        decoder = JSValueDecoder()
    }

    func testArrayOfInts() {
        let value = context.evaluateScript("""
        [1, 2, 3];
        """)
        XCTAssertNotNil(value)
        let result = try? decoder.decode([Int].self, from: value!)
        XCTAssertEqual(result, [1, 2, 3])
    }

    func testDecodableStruct() {
        let value = context.evaluateScript("""
        var thing = {"foo": "bar", "bar": 5};
        thing;
        """)
        XCTAssertNotNil(value)
        do {
            let result = try decoder.decode(TestStruct.self, from: value!)
            XCTAssertEqual(result.foo, "bar")
            XCTAssertEqual(result.bar, 5)
        } catch {
            NSLog("Error: \(error)")
            XCTFail("couldn't decode")
        }
    }

    private struct TestStruct: Decodable {
        let foo: String
        let bar: Int
    }
}
