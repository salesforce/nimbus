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
    var bridge = WebViewBridge()
    var expectPlugin = ExpectPlugin()
    var testPlugin = TestPlugin()

    override func setUp() {
        expectPlugin = ExpectPlugin()
        testPlugin = TestPlugin()
        webView = WKWebView()
        bridge = WebViewBridge()
        loadWebViewAndWait()
        XCTAssertTrue(expectPlugin.isReady)
    }

    func loadWebViewAndWait() {
        let readyExpectation = expectation(description: "ready")
        expectPlugin.readyExpectation = readyExpectation
        bridge.addPlugin(expectPlugin)
        bridge.addPlugin(testPlugin)
        bridge.attach(to: webView)

        // load nimbus.js
        if let jsURL = Bundle(for: SharedTestsWebView.self).url(forResource: "nimbus", withExtension: "js", subdirectory: "iife"),
            let jsString = try? String(contentsOf: jsURL) {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        } else {
            // when running from swiftpm, look for the file relative to the source root
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/nimbus-bridge/dist/iife/nimbus.js", relativeTo: basepath)
            if FileManager().fileExists(atPath: url.absoluteURL.path), let script = try? String(contentsOf: url) {
                let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
                webView.configuration.userContentController.addUserScript(userScript)
            }
        }

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

    func testAllTests() { // swiftlint:disable:this function_body_length
        executeTest("verifyNullaryResolvingToInt()")
        executeTest("verifyNullaryResolvingToDouble()")
        executeTest("verifyNullaryResolvingToDouble()")
        executeTest("verifyNullaryResolvingToString()")
        executeTest("verifyNullaryResolvingToStruct()")
        executeTest("verifyNullaryResolvingToIntList()")
        executeTest("verifyNullaryResolvingToDoubleList()")
        executeTest("verifyNullaryResolvingToStringList()")
        executeTest("verifyNullaryResolvingToStructList()")
        executeTest("verifyNullaryResolvingToIntArray()")
        executeTest("verifyNullaryResolvingToStringStringMap()")
        executeTest("verifyNullaryResolvingToStringIntMap()")
        executeTest("verifyNullaryResolvingToStringDoubleMap()")
        executeTest("verifyNullaryResolvingToStringStructMap()")
        executeTest("verifyUnaryIntResolvingToInt()")
        executeTest("verifyUnaryDoubleResolvingToDouble()")
        executeTest("verifyUnaryStringResolvingToInt()")
        executeTest("verifyUnaryStructResolvingToJsonString()")
        executeTest("verifyUnaryStringListResolvingToString()")
        executeTest("verifyUnaryIntListResolvingToString()")
        executeTest("verifyUnaryDoubleListResolvingToString()")
        executeTest("verifyUnaryStructListResolvingToString()")
        executeTest("verifyUnaryIntArrayResolvingToString()")
        executeTest("verifyUnaryStringStringMapResolvingToString()")
        executeTest("verifyUnaryStringStructMapResolvingToString()")
        executeTest("verifyNullaryResolvingToStringCallback()")
        executeTest("verifyNullaryResolvingToIntCallback()")
        executeTest("verifyNullaryResolvingToDoubleCallback()")
        executeTest("verifyNullaryResolvingToStructCallback()")
        executeTest("verifyNullaryResolvingToStringListCallback()")
        executeTest("verifyNullaryResolvingToIntListCallback()")
        executeTest("verifyNullaryResolvingToDoubleListCallback()")
        executeTest("verifyNullaryResolvingToStructListCallback()")
        executeTest("verifyNullaryResolvingToIntArrayCallback()")
        executeTest("verifyNullaryResolvingToStringStringMapCallback()")
        executeTest("verifyNullaryResolvingToStringIntMapCallback()")
        executeTest("verifyNullaryResolvingToStringDoubleMapCallback()")
        executeTest("verifyNullaryResolvingToStringStructMapCallback()")
        executeTest("verifyNullaryResolvingToStringIntCallback()")
        executeTest("verifyNullaryResolvingToIntStructCallback()")
        executeTest("verifyUnaryIntResolvingToIntCallback()")
        executeTest("verifyBinaryIntDoubleResolvingToIntDoubleCallback()")
        executeTest("verifyBinaryIntResolvingIntCallbackReturnsInt()")
    }

    func testEventPublishing() {
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
