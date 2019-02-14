//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit
import XCTest

@testable import Nimbus

class UserDefinedType: Encodable {
    var intParam = 5
    var stringParam = "hello user defined type"
}

class CallJavascriptTests: XCTestCase, WKNavigationDelegate {
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
        wait(for: [loadingExpectation!], timeout: 10)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testCallMethodWithNoParam() throws {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        webView.evaluateJavaScript("function testFunction() { return true; }") { _, _ in

            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "js result")
        var returnValue = false
        webView.callJavascript(name: "testFunction", args: []) { result, _ -> Void in
            if let result = result as? Bool {
                returnValue = result
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertTrue(returnValue)
    }

    func testCallNonExistingMethodReturnsAnError() {
        loadWebViewAndWait()

        let expect = expectation(description: "js result")
        var error: Error?
        webView.callJavascript(name: "methodThatDoesntExist", args: []) { _, callError in
            error = callError
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)

        XCTAssertEqual(error?.localizedDescription, .some("A JavaScript exception occurred"))
    }

    func testCallMethodWithMultipleParams() {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
        function testFunctionWithArgs(...args) {
          return JSON.stringify(args);
        }
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "js result")
        let optional: Int? = nil
        let args: [Encodable] = [true, 42, optional, "hello\nworld", UserDefinedType()]
        var result: String?
        webView.callJavascript(name: "testFunctionWithArgs", args: args) { callResult, _ in
            if let callResult = callResult as? String {
                result = callResult
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)

        XCTAssertEqual(result, .some("[true,42,null,\"hello\\nworld\",{\"stringParam\":\"hello user defined type\",\"intParam\":5}]"))
    }

    func testCallMethodOnAnObject() {
        loadWebViewAndWait()

        let setup = expectation(description: "setup")
        let script = """
        class MyObject {
          getName() { return "nimbus"; }
        };
        testObject = new MyObject();
        """
        webView.evaluateJavaScript(script) { _, _ in
            setup.fulfill()
        }
        wait(for: [setup], timeout: 10)

        let expect = expectation(description: "js result")
        var resultValue: String?
        webView.callJavascript(name: "testObject.getName", args: []) { result, _ in
            if let result = result as? String {
                resultValue = result
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertEqual(resultValue, .some("nimbus"))
    }
}
