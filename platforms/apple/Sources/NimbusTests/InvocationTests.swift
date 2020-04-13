//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit
import XCTest

@testable import Nimbus

class InvocationTests: XCTestCase, WKNavigationDelegate {
    var webView: WKWebView!
    var loadingExpectation: XCTestExpectation?
    var bridge = Bridge()

    override func setUp() {
        webView = WKWebView()
        webView.navigationDelegate = self
        bridge.attach(to: webView)
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
    }

    func loadWebViewAndWait() {
        loadingExpectation = expectation(description: "web view loaded")
        loadingExpectation?.assertForOverFulfill = false

        if let url = Bundle(for: InvocationTests.self).url(forResource: "index", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        else {
            // when running from swiftpm, look for the file relative to the source root
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/test-www/dist/test-www/index.html", relativeTo: basepath)
            if FileManager().fileExists(atPath: url.absoluteURL.path) {
                webView.loadFileURL(url.absoluteURL, allowingReadAccessTo: url.absoluteURL)
            }
        }

        wait(for: [loadingExpectation!], timeout: 10)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testInvokePromiseResolved() throws {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
        function promiseFunc() { return Promise.resolve(42); }
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "invocation result")
        var rejectedError: Error?
        var resolvedValue: Int?
        bridge.invoke("promiseFunc") { (error, result: Int?) in
            rejectedError = error
            resolvedValue = result
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
        XCTAssertNil(rejectedError)
        XCTAssertEqual(resolvedValue, 42)
    }

    func testInvokePromiseRejected() throws {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
        function promiseFunc() { return Promise.reject(new Error("epic fail")); }
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "invocation result")
        var rejectedError: Error?
        var resolvedValue: Int?
        bridge.invoke("promiseFunc") { (error, result: Int?) in
            rejectedError = error
            resolvedValue = result
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
        XCTAssertNil(resolvedValue)
        guard
            let promiseError = rejectedError as? PromiseError,
            case let .message(message) = promiseError
        else {
            return XCTFail("Unexpected error \(String(describing: rejectedError))")
        }
        XCTAssertEqual(message, "Error: epic fail")
    }

    func testInvokePromiseRejectedOnRefresh() throws {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
           function promiseFunc() { return new Promise((resolve, reject) => {}); }
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "invocation result")
        var rejectedError: Error?
        var resolvedValue: Int?
        bridge.invoke("promiseFunc") { (error, result: Int?) in
            rejectedError = error
            resolvedValue = result
            expect.fulfill()
        }

        webView.reload()

        wait(for: [expect], timeout: 5)
        XCTAssertNil(resolvedValue)
        XCTAssertEqual(PromiseError.pageUnloaded, rejectedError as? PromiseError)
    }

    func testInvokePromiseResolvingToVoid() throws {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
           function promiseFunc() { return Promise.resolve(); }
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "invocation result")
        var rejectedError: Error?
        var resolvedValue: Void?
        bridge.invoke("promiseFunc") { (error, result: Void?) in
            rejectedError = error
            resolvedValue = result
            expect.fulfill()
        }

        webView.reload()

        wait(for: [expect], timeout: 5)
        XCTAssertNil(rejectedError)
        XCTAssertNil(resolvedValue)
    }
}
