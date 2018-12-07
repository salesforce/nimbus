/**
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


import XCTest
import WebKit

@testable import Veil

class WebViewTestBridge {
}

class WebViewTests: XCTestCase, WKNavigationDelegate {

    let bridge = WebViewTestBridge()
    var webView: WKWebView!

    var loadingExpectation: XCTestExpectation?

    override func setUp() {
        webView = WKWebView()
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
    }

    func loadWebViewAndWait(html: String = "<html><body></body></html>") {
        loadingExpectation = expectation(description: "web view loaded")
        webView.loadHTMLString(html, baseURL: nil)
        wait(for: [loadingExpectation!], timeout: 5)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testAddingConnectionCreatesNamespace() {
        let _ = webView.addConnection(to: bridge, as: "WebViewTestBridge")

        let x = expectation(description: "js result")
        var namespaceExists = false
        webView.evaluateJavaScript("window.webkit.messageHandlers.WebViewTestBridge !== undefined") { (result, error) in
            if case let .some(value as Bool) = result {
                namespaceExists = value
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(namespaceExists)
    }

    func testAddingConnectionLoadsVeilUserScript() {
        let _ = webView.addConnection(to: bridge, as: "WebViewTestBridge")
        let x = expectation(description: "js result")
        var resolvePromiseExists = false

        loadWebViewAndWait()

        webView.evaluateJavaScript("resolvePromise !== undefined") { (result, error) in
            if case let .some(value as Bool) = result {
                resolvePromiseExists = value
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(resolvePromiseExists)
    }
}
