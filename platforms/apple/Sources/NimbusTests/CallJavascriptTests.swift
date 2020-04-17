//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore
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
    var bridge: Bridge!

    override func setUp() {
        webView = WKWebView()
        bridge = Bridge()
        bridge.attach(to: webView)
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        bridge = nil
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
        bridge.invoke("testFunction") { (_, result: Any?) -> Void in
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
        bridge.invoke("methodThatDoesntExist") { (callError, _: Any?) in
            error = callError
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)

        XCTAssertEqual(error?.localizedDescription, .some("The operation couldn’t be completed. (Nimbus.PromiseError error 0.)"))
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
        var result: String?
        bridge.invoke(
            "testFunctionWithArgs",
           with: true, 42, optional, "hello\nworld", UserDefinedType()
        ) { (_, callResult: Any?) in
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
        bridge.invoke("testObject.getName") { (_, result: Any?) in
            if let result = result as? String {
                resultValue = result
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertEqual(resultValue, .some("nimbus"))
    }
}

class CallJSContextTests: XCTestCase {
    var context: JSContext = JSContext()
    var bridge: JSContextBridge = JSContextBridge()

    override func setUp() {
        context = JSContext()
        bridge = JSContextBridge()
        bridge.attach(to: context)
        context.evaluateScript(fixtureScript)
    }

    func testCallFunction() throws {
        let expect = expectation(description: "test call function")
        var resultValue: Bool?
        bridge.invoke("testFunction") { (_, result) in
            if let result = result, result.isBoolean {
                resultValue = result.toBool()
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertEqual(resultValue, true)
    }

    let fixtureScript = """
    function testFunction() { return true; };
    """
}
