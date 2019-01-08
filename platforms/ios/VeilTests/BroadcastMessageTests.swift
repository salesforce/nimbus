// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

import XCTest
import WebKit

@testable import Veil

class BroadcastMessageTests: XCTestCase, WKNavigationDelegate {
    let bridge = ConnectionTestBridge()
    var webView: WKWebView!
    var loadingExpectation: XCTestExpectation?

    override func setUp() {
        let userContentController = WKUserContentController()
        let appScript = Bundle(for: EvalJsTests.self).url(forResource: "broadcastJs", withExtension: "js")
            .flatMap { try? NSString(contentsOf: $0, encoding: String.Encoding.utf8.rawValue ) }
            .flatMap { WKUserScript(source: $0 as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true) }
        if let appScript = appScript {
            userContentController.addUserScript(appScript)
        }
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        self.webView.navigationDelegate = self
        let _ = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
    }

    override func tearDown() {
        self.webView.navigationDelegate = nil
        self.webView = nil
    }

    func loadWebViewAndWait(html: String = "<html><body></body></html>") {
        loadingExpectation = expectation(description: "web view loaded")
        self.webView.loadHTMLString(html, baseURL: nil)
        wait(for: [loadingExpectation!], timeout: 10)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testBroadcastMessageWithNoParam() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var callCountMatches = false
        self.webView.broadcastMessage(name: "testMessageWithNoParam") { (calledHandlerCount, error) -> () in
            if 1 == calledHandlerCount {
                callCountMatches = true
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(callCountMatches)
    }

    func testBroadcastMessageWithParam() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var callCountMatches = false
        let testArg = UserDefinedType()
        self.webView.broadcastMessage(name: "testMessageWithParam", arg: testArg) { (calledHandlerCount, error) -> () in
            if 1 == calledHandlerCount {
                callCountMatches = true
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(callCountMatches)
    }

    func testBroadcastMessageWithNoHandler() {
        loadWebViewAndWait()
        // Test unsubscribing of a message handler
        let x = expectation(description: "js result")
        var callCountMatches = false
        self.webView.broadcastMessage(name: "testUnsubscribingHandler") { (calledHandlerCount, error) -> () in
            if 1 == calledHandlerCount {
                callCountMatches = true
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(callCountMatches)

        // Test that no message handler is called
        let y = expectation(description: "js result")
        callCountMatches = false
        self.webView.broadcastMessage(name: "testMessageWithNoParam") { (calledHandlerCount, error) -> () in
            if 0 == calledHandlerCount {
                callCountMatches = true
            }
            y.fulfill()
        }
        wait(for: [y], timeout: 5)
        XCTAssertTrue(callCountMatches)
    }
}
