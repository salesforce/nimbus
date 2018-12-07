// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


import XCTest
import WebKit

@testable import Veil

class ConnectionTestBridge {

    private(set) var calledFoo = false

    var callbackExpectation: XCTestExpectation?
    var callbackResult: Int = 0

    func foo() {
        calledFoo = true
    }

    func fulfillCallbackExpectation(result: Int) {
        callbackResult = result
        callbackExpectation?.fulfill()
        callbackExpectation = nil
    }

    func unaryWithCallback(callback: (Int) -> ()) {
        callback(42)
    }

    func binaryWithCallback(arg0: Int, callback: (Int) -> ()) {
        callback(arg0 * arg0);
    }

    func ternaryWithCallback(arg0: Float, arg1: Float, callback: (Float) -> ()) {
        callback(pow(arg0, arg1))
    }

    func quaternaryWithCallback(arg0: Int, arg1: Int, arg2: Int, callback: (Int) -> ()) {
        callback(arg0 * arg1 * arg2)
    }

    func quinaryWithCallback(arg0: Int, arg1: Int, arg2: Int, arg3: Int, callback: (Int) -> ()) {
        callback(arg0 + arg1 + arg2 + arg3)
    }
}

class ConnectionTests: XCTestCase, WKNavigationDelegate {

    let bridge = ConnectionTestBridge()
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

    func testCreatingConnectionCreatesNamespace() {

        let _ = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")

        loadWebViewAndWait()

        let x = expectation(description: "js result")
        var namespaceExists = false
        webView.evaluateJavaScript("window.webkit.messageHandlers.ConnectionTestBridge !== undefined") { (result, error) in
            if case let .some(value as Bool) = result {
                namespaceExists = value
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(namespaceExists)
    }

    func testCreatingConnectionWithBindingCreatesStub() {

        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.foo, as: "foo")

        loadWebViewAndWait()

        let x = expectation(description: "js result")
        var stubExists = false
        webView.evaluateJavaScript("ConnectionTestBridge.foo !== undefined") { (result, error) in
            if case let .some(value as Bool) = result {
                stubExists = value
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(stubExists)
    }

    func testCallingBoundFunctionWorks() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.foo, as: "foo")

        loadWebViewAndWait()

        let x = expectation(description: "js result")
        webView.evaluateJavaScript("ConnectionTestBridge.foo();") { (result, error) in
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(bridge.calledFoo)
    }

    func testBindingUnaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.unaryWithCallback, as: "unaryWithCallback")
        c.bind(ConnectionTestBridge.fulfillCallbackExpectation, as: "fulfillCallbackExpectation")
        loadWebViewAndWait()

        let callbackExpectation = expectation(description: "callback")
        bridge.callbackExpectation = callbackExpectation
        webView.evaluateJavaScript("""
            ConnectionTestBridge.unaryWithCallback((v) => {
               ConnectionTestBridge.fulfillCallbackExpectation(v);
            });
            true;
        """)

        wait(for: [callbackExpectation], timeout: 5)
        XCTAssertEqual(42, bridge.callbackResult)
    }

    func testBindingBinaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.binaryWithCallback, as: "binaryWithCallback")
        c.bind(ConnectionTestBridge.fulfillCallbackExpectation, as: "fulfillCallbackExpectation")
        loadWebViewAndWait()

        let callbackExpectation = expectation(description: "callback")
        bridge.callbackExpectation = callbackExpectation
        webView.evaluateJavaScript("""
            ConnectionTestBridge.binaryWithCallback(9, (v) => {
               ConnectionTestBridge.fulfillCallbackExpectation(v);
            });
            true;
        """)

        wait(for: [callbackExpectation], timeout: 5)
        XCTAssertEqual(81, bridge.callbackResult)
    }

    func testBindingTernaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.ternaryWithCallback, as: "ternaryWithCallback")
        c.bind(ConnectionTestBridge.fulfillCallbackExpectation, as: "fulfillCallbackExpectation")
        loadWebViewAndWait()

        let callbackExpectation = expectation(description: "callback")
        bridge.callbackExpectation = callbackExpectation
        webView.evaluateJavaScript("""
            ConnectionTestBridge.ternaryWithCallback(2, 10, (v) => {
               ConnectionTestBridge.fulfillCallbackExpectation(v);
            });
            true;
        """)

        wait(for: [callbackExpectation], timeout: 5)
        XCTAssertEqual(1024, bridge.callbackResult)
    }

    func testBindingQuaternaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.quaternaryWithCallback, as: "quaternaryWithCallback")
        c.bind(ConnectionTestBridge.fulfillCallbackExpectation, as: "fulfillCallbackExpectation")
        loadWebViewAndWait()

        let callbackExpectation = expectation(description: "callback")
        bridge.callbackExpectation = callbackExpectation
        webView.evaluateJavaScript("""
            ConnectionTestBridge.quaternaryWithCallback(3, 4, 5, (v) => {
               ConnectionTestBridge.fulfillCallbackExpectation(v);
            });
            true;
        """)

        wait(for: [callbackExpectation], timeout: 5)
        XCTAssertEqual(60, bridge.callbackResult)
    }

    func testBindingQuinaryWithCallback() {
        let c = Connection(from: webView, to: bridge, as: "ConnectionTestBridge")
        c.bind(ConnectionTestBridge.quinaryWithCallback, as: "quinaryWithCallback")
        c.bind(ConnectionTestBridge.fulfillCallbackExpectation, as: "fulfillCallbackExpectation")
        loadWebViewAndWait()

        let callbackExpectation = expectation(description: "callback")
        bridge.callbackExpectation = callbackExpectation
        webView.evaluateJavaScript("""
            ConnectionTestBridge.quinaryWithCallback(1, 2, 3, 4, (v) => {
               ConnectionTestBridge.fulfillCallbackExpectation(v);
            });
            true;
        """)

        wait(for: [callbackExpectation], timeout: 5)
        XCTAssertEqual(10, bridge.callbackResult)
    }

}
