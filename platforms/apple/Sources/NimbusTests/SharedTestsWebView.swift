//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit
import XCTest
@testable import Nimbus

class SharedTestsWebView: XCTestCase {
    var webView = WKWebView()
    var bridge: WebViewBridge?
    var expectPlugin = ExpectPlugin()
    var testPlugin = TestPlugin()

    override func setUp() {
        expectPlugin = ExpectPlugin()
        testPlugin = TestPlugin()
        webView = WKWebView()
        bridge = BridgeBuilder.createBridge(for: webView, plugins: [expectPlugin, testPlugin])
        loadWebViewAndWait()
        XCTAssertTrue(expectPlugin.isReady)
    }

    func loadWebViewAndWait() {
        let readyExpectation = expectation(description: "ready")
        expectPlugin.readyExpectation = readyExpectation

        // load nimbus.js
        try? webView.injectNimbusJavascript()

        // load shared-tests.js
        if let jsURL = Bundle(for: SharedTestsWebView.self).url(forResource: "shared-tests", withExtension: "js", subdirectory: "test-www"),
            let jsString = try? String(contentsOf: jsURL) {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        } else {
            // when running from swiftpm, look for the file relative to the source root
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/test-www/dist/test-www/shared-tests.js", relativeTo: basepath)
            if FileManager().fileExists(atPath: url.absoluteURL.path), let script = try? String(contentsOf: url) {
                let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
                webView.configuration.userContentController.addUserScript(userScript)
            }
        }

        // load the html
        if let htmlURL = Bundle(for: SharedTestsWebView.self).url(forResource: "shared-tests", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)
        } else {
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/test-www/dist/test-www/shared-tests.html", relativeTo: basepath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

        wait(for: [readyExpectation], timeout: 5)
    }

    func executeTest(_ testName: String) {
        expectPlugin.reset()
        expectPlugin.finishedExpectation = expectation(description: testName)
        webView.evaluateJavaScript(testName, completionHandler: nil)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(expectPlugin.isFinished)
        XCTAssertTrue(expectPlugin.passed, "Failed: \(testName)")
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

    func testVerifyUnaryCallbackEncodable() {
        executeTest("verifyUnaryCallbackEncodable()")
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

    func testVerifyBinaryIntResolvingIntCallbackReturnsInt() {
        executeTest("verifyBinaryIntResolvingIntCallbackReturnsInt()")
    }

    func testVerifyReturnValueSimpleError() {
        executeTest("verifyReturnValueSimpleError()")
    }

    func testVerifyReturnValueStructuredError() {
        executeTest("verifyReturnValueStructuredError()")
    }

    func testVerifyStringDecoderRejectsInt() {
        executeTest("verifyStringDecoderRejectsInt()")
    }

    func testVerifyStringDecoderRejectsBool() {
        executeTest("verifyStringDecoderRejectsBool()")
    }

    func testVerifyStringDecoderRejectsObject() {
        executeTest("verifyStringDecoderRejectsObject()")
    }

    func testVerifyStringDecoderRejectsNull() {
        executeTest("verifyStringDecoderRejectsNull()")
    }

    func testVerifyStringDecoderRejectsUndefined() {
        executeTest("verifyStringDecoderRejectsUndefined()")
    }

    func testVerifyNumberDecoderRejectsString() {
        executeTest("verifyNumberDecoderRejectsString()")
    }

    func testVerifyNumberDecoderRejectsObject() {
        executeTest("verifyNumberDecoderRejectsObject()")
    }

    func testVerifyNumberDecoderRejectsNull() {
        executeTest("verifyNumberDecoderRejectsNull()")
    }

    func testVerifyNumberDecoderRejectsUndefined() {
        executeTest("verifyNumberDecoderRejectsUndefined()")
    }

    func testVerifyBoolDecoderRejectsString() {
        executeTest("verifyBoolDecoderRejectsString()")
    }

    func testVerifyBoolDecoderRejectsObject() {
        executeTest("verifyBoolDecoderRejectsObject()")
    }

    func testVerifyBoolDecoderRejectsNull() {
        executeTest("verifyBoolDecoderRejectsNull()")
    }

    func testVerifyBoolDecoderRejectsUndefined() {
        executeTest("verifyBoolDecoderRejectsUndefined()")
    }

    func testVerifyDictionaryDecoderRejectsString() {
        executeTest("verifyDictionaryDecoderRejectsString()")
    }

    func testVerifyDictionaryDecoderRejectsInt() {
        executeTest("verifyDictionaryDecoderRejectsInt()")
    }

    func testVerifyDictionaryDecoderRejectsBool() {
        executeTest("verifyDictionaryDecoderRejectsBool()")
    }

    func testVerifyDictionaryDecoderRejectsNull() {
        executeTest("verifyDictionaryDecoderRejectsNull()")
    }

    func testVerifyDictionaryDecoderRejectsUndefined() {
        executeTest("verifyDictionaryDecoderRejectsUndefined()")
    }

    func testVerifyTestStructDecoderRejectsString() {
        executeTest("verifyTestStructDecoderRejectsString()")
    }

    func testVerifyTestStructDecoderRejectsInt() {
        executeTest("verifyTestStructDecoderRejectsInt()")
    }

    func testVerifyTestStructDecoderRejectsBool() {
        executeTest("verifyTestStructDecoderRejectsBool()")
    }

    func testVerifyTestStructDecoderRejectsNull() {
        executeTest("verifyTestStructDecoderRejectsNull()")
    }

    func testVerifyTestStructDecoderRejectsUndefined() {
        executeTest("verifyTestStructDecoderRejectsUndefined()")
    }

    func testEventPublishing() {
        expectPlugin.readyExpectation = expectation(description: "ready")
        let subscribe = expectation(description: "subscribe")
        webView.evaluateJavaScript("subscribeToStructEvent()") { _, _ in
            subscribe.fulfill()
        }
        wait(for: [subscribe], timeout: 20)
        XCTAssertTrue(expectPlugin.isReady)
        expectPlugin.reset()
        expectPlugin.finishedExpectation = expectation(description: "events")
        testPlugin.publishStructEvent()
        waitForExpectations(timeout: 20, handler: nil)
        XCTAssertTrue(expectPlugin.isFinished)
        XCTAssertTrue(expectPlugin.passed, "Failed Event Publishing")

        let invert = expectation(description: "inverted")
        invert.isInverted = true
        expectPlugin.finishedExpectation = invert
        expectPlugin.readyExpectation = expectation(description: "ready")
        expectPlugin.isReady = false
        let unsubscribe = expectation(description: "unsubscribe")
        webView.evaluateJavaScript("unsubscribeFromStructEvent()") { _, _ in
            unsubscribe.fulfill()
        }
        wait(for: [unsubscribe], timeout: 20)
        XCTAssertTrue(expectPlugin.isReady)
        testPlugin.publishStructEvent()
        waitForExpectations(timeout: 2)
    }
}
