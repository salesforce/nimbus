//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import XCTest
@testable import Nimbus

class DecodableUtilsTests: XCTestCase {

    func testDecodableSucceeds() {
        guard let data = successJSON.data(using: .utf8) else {
            XCTFail("couldn't make data from JSON")
            return
        }
        let testValue = decodeJSON(data, destinationType: TestStruct.self)
        XCTAssertNotNil(testValue)
    }

    func testNotDecodableFails() {
        guard let data = successJSON.data(using: .utf8) else {
            XCTFail("couldn't make data from JSON")
            return
        }
        let testValue = decodeJSON(data, destinationType: FailTestStruct.self)
        XCTAssertNil(testValue)
    }

    func testDecodableWithIncompatibleStringFails() {
        guard let data = failJSON.data(using: .utf8) else {
            XCTFail("couldn't make data from JSON")
            return
        }
        let testValue = decodeJSON(data, destinationType: TestStruct.self)
        XCTAssertNil(testValue)
    }

    struct TestStruct: Decodable {
        let number: Int
        let name: String
        let list: [String]
    }

    struct FailTestStruct {
        let number: Int
        let name: String
        let list: [String]
    }

    let successJSON = """
    {
        "number": 42,
        "name": "TheName",
        "list": ["One", "Two", "Three"]
    }
    """

    let failJSON = """
    {
        "blah": "blah"
    }
    """

}
