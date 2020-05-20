//
//  SharedTestsWebView.swift
//  NimbusTests
//
//  Created by Paul Tiarks on 5/19/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import XCTest
import WebKit
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
    }

    func loadWebViewAndWait() {
        let readyExpectation = expectation(description: "ready")
        expectPlugin.readyExpectation = readyExpectation
        bridge.addPlugin(expectPlugin)
        bridge.addPlugin(testPlugin)
        bridge.attach(to: webView)

        //load nimbus.js
        if let jsURL = Bundle(for: SharedTestsWebView.self).url(forResource: "nimbus", withExtension: "js", subdirectory: "iife"),
            let jsString = try? String(contentsOf: jsURL) {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        } else {
            XCTFail("couldn't get nimbus js")
        }

        //load shared-tests.js
        if let jsURL = Bundle(for: SharedTestsWebView.self).url(forResource: "shared-tests", withExtension: "js", subdirectory: "test-www"),
            let jsString = try? String(contentsOf: jsURL) {
            let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        } else {
            XCTFail("couldn't get test js")
        }

        // load the html
        if let htmlURL = Bundle(for: SharedTestsWebView.self).url(forResource: "shared-tests", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)
        } else {
            XCTFail("couldn't get the test html")
        }

        wait(for: [readyExpectation], timeout: 60)
    }

    func executeTest(_ testName: String) {
        loadWebViewAndWait()
        XCTAssertTrue(expectPlugin.isReady)
        expectPlugin.reset()
        expectPlugin.finishedExpectation = expectation(description: testName)
        webView.evaluateJavaScript(testName, completionHandler: nil)
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(expectPlugin.isFinished)
        XCTAssertTrue(expectPlugin.passed, "Failed: \(testName)")
    }

    func testAllTests() { //swiftlint:disable:this function_body_length
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
//        executeTest("verifyNullaryResolvingToDoubleIntStructCallback()")
        executeTest("verifyUnaryIntResolvingToIntCallback()")
        executeTest("verifyBinaryIntDoubleResolvingToIntDoubleCallback()")
    }
}
