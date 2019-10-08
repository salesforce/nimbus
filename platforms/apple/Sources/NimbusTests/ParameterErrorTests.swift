//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

@testable import Nimbus
import XCTest

class ParameterErrorTests: XCTestCase {

    func noArgs() {
    }

    func threeArgs(one: Int, two: Int, three: Int) {
    }

    func testTooFewArgsError() {
        let callable = make_callable(self.threeArgs)
        XCTAssertThrowsError(try callable.call(args: [1, 2])) { error in
            guard let paramError = error as? ParameterError else {
                return XCTFail("Expected argument count error, not \(error)")
            }
            XCTAssertEqual(paramError, .argumentCount(expected: 3, actual: 2))
        }
    }

    func testTooManyArgsError() {
        let callable = make_callable(ParameterErrorTests.noArgs(self))
        XCTAssertThrowsError(try callable.call(args: [1, 2, 3, 4, 5])) { error in
            guard let paramError = error as? ParameterError else {
                    return XCTFail("Expected argument count error, not \(error)")
            }
            XCTAssertEqual(paramError, .argumentCount(expected: 0, actual: 5))
        }
    }
}
