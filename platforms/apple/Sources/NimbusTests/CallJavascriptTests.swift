//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
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
    var bridge: WebViewBridge?

    override func setUp() {
        webView = WKWebView()
        bridge = BridgeBuilder.createBridge(for: webView, plugins: [])
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
        wait(for: [loadingExpectation!], timeout: 60)
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
        bridge!.invoke(["testFunction"], with: []) { (_, result: Any?) -> Void in
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
        bridge!.invoke(["methodThatDoesntExist"], with: []) { (callError, _: Any?) in
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
        bridge!.invoke(
            ["testFunctionWithArgs"],
            with: [true, 42, optional, "hello\nworld", UserDefinedType()]
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
        bridge!.invoke(["testObject", "getName"], with: []) { (_, result: Any?) in
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
    var bridge: JSContextBridge?

    override func setUp() {
        context = JSContext()
        bridge = BridgeBuilder.createBridge(for: context, plugins: [])
        context.evaluateScript(fixtureScript)
    }

    func testCallFunction() throws {
        let expect = expectation(description: "test call function")
        var resultValue: Bool?
        bridge!.invoke(["testFunction"]) { _, result in
            if let result = result, result.isBoolean {
                resultValue = result.toBool()
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertEqual(resultValue, true)
    }

    func testCallNonExistentFunction() throws {
        let expect = expectation(description: "non existent function")
        var result: JSValue?
        var error: Error?
        bridge!.invoke(["somethingthatdoesntexist"]) { theError, theResult in
            error = theError
            result = theResult
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertNil(result)
        XCTAssertEqual(error?.localizedDescription, "The operation couldn’t be completed. (Nimbus.JSContextBridgeError error 1.)")
    }

    func testCallWithMultipleArguments() throws {
        let expect = expectation(description: "multiple arguments")
        var result: JSValue?
        var error: Error?
        bridge!.invoke(["testFunctionWithArgs"], with: [5, "athing", 15]) { theError, theResult in
            result = theResult
            error = theError
            expect.fulfill()
        }

        wait(for: [expect], timeout: 5)
        XCTAssertNil(error)
        XCTAssertTrue(result?.isArray ?? false)
        XCTAssertEqual(result?.objectAtIndexedSubscript(0)?.toInt32(), 5)
        XCTAssertEqual(result?.objectAtIndexedSubscript(1)?.toString(), "athing")
        XCTAssertEqual(result?.objectAtIndexedSubscript(2)?.toInt32(), 15)
    }

    func testCallFunctionOnObject() throws {
        let expect = expectation(description: "call function on object")
        var error: Error?
        var result: JSValue?
        bridge!.invoke(["testObject", "getName"]) { theError, theResult in
            error = theError
            result = theResult
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        XCTAssertNil(error)
        XCTAssertEqual(result?.toString(), "nimbus")
    }

    let fixtureScript = """
    function testFunction() { return true; };
    function testFunctionWithArgs(...args) {
      return Array.prototype.slice.apply(args);
    };
    class MyObject {
      getName() { return "nimbus"; }
    };
    testObject = new MyObject();
    """
}
