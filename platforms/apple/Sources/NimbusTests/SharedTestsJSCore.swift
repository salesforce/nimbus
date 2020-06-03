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

class SharedTestsJSCore: XCTestCase {
    var context = JSContext()!
    var bridge = JSContextBridge()
    var expectPlugin = ExpectPlugin()
    var testPlugin = TestPlugin()

    override func setUp() {
        expectPlugin = ExpectPlugin()
        expectPlugin.finishedExpectation = expectation(description: "expectPlugin")
        testPlugin = TestPlugin()
        context = JSContext()!
        bridge = JSContextBridge()
        bridge.addPlugin(expectPlugin)
        bridge.addPlugin(testPlugin)
        bridge.attach(to: context)

        if let jsURL = Bundle(for: SharedTestsJSCore.self).url(forResource: "shared-tests", withExtension: "js", subdirectory: "test-www"),
            let jsString = try? String(contentsOf: jsURL) {
            context.evaluateScript(jsString)
            context.evaluateScript("__nimbus.plugins.expectPlugin.ready();")
        } else {
            // when running from swiftpm, look for the file relative to the source root
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/test-www/dist/test-www/shared-tests.js", relativeTo: basepath)
            if FileManager().fileExists(atPath: url.absoluteURL.path), let script = try? String(contentsOf: url) {
                context.evaluateScript(script)
                context.evaluateScript("__nimbus.plugins.expectPlugin.ready();")
            }
        }
    }

    func executeTest(_ testName: String) {
        XCTAssertTrue(expectPlugin.isReady)
        context.evaluateScript(testName)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(expectPlugin.isFinished)
        XCTAssertTrue(expectPlugin.passed)
    }

    func testVerifyNullaryResolvingToInt() {
        executeTest("verifyNullaryResolvingToInt()")
    }

    func testVerifyNullaryResolvingToDouble() {
        executeTest("verifyNullaryResolvingToDouble()")
    }

    func testVerifyNullaryResolvingToString() {
        executeTest("verifyNullaryResolvingToString()")
    }

    func testVerifyNullaryResolvingToStruct() {
        executeTest("verifyNullaryResolvingToStruct()")
    }

    func testVerifyNullaryResolvingToIntList() {
        executeTest("verifyNullaryResolvingToIntList()")
    }

    func testVerifyNullaryResolvingToDoubleList() {
        executeTest("verifyNullaryResolvingToDoubleList()")
    }

    func testVerifyNullaryResolvingToStringList() {
        executeTest("verifyNullaryResolvingToStringList()")
    }

    func testVerifyNullaryResolvingToStructList() {
        executeTest("verifyNullaryResolvingToStructList()")
    }

    func testVerifyNullaryResolvingToIntArray() {
        executeTest("verifyNullaryResolvingToIntArray()")
    }

    func testVerifyNullaryResolvingToStringStringMap() {
        executeTest("verifyNullaryResolvingToStringStringMap()")
    }

    func testVerifyNullaryResolvingToStringIntMap() {
        executeTest("verifyNullaryResolvingToStringIntMap()")
    }

    func testVerifyNullaryResolvingToStringDoubleMap() {
        executeTest("verifyNullaryResolvingToStringDoubleMap()")
    }

    func testVerifyNullaryResolvingToStringStructMap() {
        executeTest("verifyNullaryResolvingToStringStructMap()")
    }

    func testVerifyUnaryIntResolvingToInt() {
        executeTest("verifyUnaryIntResolvingToInt()")
    }

    func testVerifyUnaryDoubleResolvingToDouble() {
        executeTest("verifyUnaryDoubleResolvingToDouble()")
    }

    func testVerifyUnaryStringResolvingToInt() {
        executeTest("verifyUnaryStringResolvingToInt()")
    }

    func testVerifyUnaryStructResolvingToJsonString() {
        executeTest("verifyUnaryStructResolvingToJsonString()")
    }

    func testVerifyUnaryStringListResolvingToString() {
        executeTest("verifyUnaryStringListResolvingToString()")
    }

    func testVerifyUnaryIntListResolvingToString() {
        executeTest("verifyUnaryIntListResolvingToString()")
    }

    func testVerifyUnaryDoubleListResolvingToString() {
        executeTest("verifyUnaryDoubleListResolvingToString()")
    }

    func testVerifyUnaryStructListResolvingToString() {
        executeTest("verifyUnaryStructListResolvingToString()")
    }

    func testVerifyUnaryIntArrayResolvingToString() {
        executeTest("verifyUnaryIntArrayResolvingToString()")
    }

    func testVerifyUnaryStringStringMapResolvingToString() {
        executeTest("verifyUnaryStringStringMapResolvingToString()")
    }

    func testVerifyUnaryStringStructMapResolvingToString() {
        executeTest("verifyUnaryStringStructMapResolvingToString()")
    }

    func testVerifyNullaryResolvingToStringCallback() {
        executeTest("verifyNullaryResolvingToStringCallback()")
    }

    func testVerifyNullaryResolvingToIntCallback() {
        executeTest("verifyNullaryResolvingToIntCallback()")
    }

    func testVerifyNullaryResolvingToDoubleCallback() {
        executeTest("verifyNullaryResolvingToDoubleCallback()")
    }

    func testVerifyNullaryResolvingToStructCallback() {
        executeTest("verifyNullaryResolvingToStructCallback()")
    }

    func testVerifyNullaryResolvingToStringListCallback() {
        executeTest("verifyNullaryResolvingToStringListCallback()")
    }

    func testVerifyNullaryResolvingToIntListCallback() {
        executeTest("verifyNullaryResolvingToIntListCallback()")
    }

    func testVerifyNullaryResolvingToDoubleListCallback() {
        executeTest("verifyNullaryResolvingToDoubleListCallback()")
    }

    func testVerifyNullaryResolvingToStructListCallback() {
        executeTest("verifyNullaryResolvingToStructListCallback()")
    }

    func testVerifyNullaryResolvingToIntArrayCallback() {
        executeTest("verifyNullaryResolvingToIntArrayCallback()")
    }

    func testVerifyNullaryResolvingToStringStringMapCallback() {
        executeTest("verifyNullaryResolvingToStringStringMapCallback()")
    }

    func testVerifyNullaryResolvingToStringIntMapCallback() {
        executeTest("verifyNullaryResolvingToStringIntMapCallback()")
    }

    func testVerifyNullaryResolvingToStringDoubleMapCallback() {
        executeTest("verifyNullaryResolvingToStringDoubleMapCallback()")
    }

    func testVerifyNullaryResolvingToStringStructMapCallback() {
        executeTest("verifyNullaryResolvingToStringStructMapCallback()")
    }

    func testVerifyNullaryResolvingToStringIntCallback() {
        executeTest("verifyNullaryResolvingToStringIntCallback()")
    }

    func testVerifyNullaryResolvingToIntStructCallback() {
        executeTest("verifyNullaryResolvingToIntStructCallback()")
    }

    func testVerifyUnaryIntResolvingToIntCallback() {
        executeTest("verifyUnaryIntResolvingToIntCallback()")
    }

    func testVerifyBinaryIntDoubleResolvingToIntDoubleCallback() {
        executeTest("verifyBinaryIntDoubleResolvingToIntDoubleCallback()")
    }

//        commented out until android support
//    func testVerifyBinaryIntResolvingIntCallbackReturnsInt() {
//        executeTest("verifyBinaryIntResolvingIntCallbackReturnsInt()")
//    }
}
