// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause

import XCTest
import WebKit

@testable import Veil

class UserDefinedType:Encodable {
    var intParam = 5
    var stringParam = "hello user defined type"
}

class EvalJsTests: XCTestCase, WKNavigationDelegate {
    
    var webView: WKWebView!
    var loadingExpectation: XCTestExpectation?
    
    override func setUp() {
        let userContentController = WKUserContentController()
        let appScript = Bundle(for: EvalJsTests.self).url(forResource: "evalJs", withExtension: "js")
            .flatMap { try? NSString(contentsOf: $0, encoding: String.Encoding.utf8.rawValue ) }
            .flatMap { WKUserScript(source: $0 as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true) }
        if let appScript = appScript {
            userContentController.addUserScript(appScript)
        }
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        self.webView.navigationDelegate = self
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

    func testCallMethodWithNoParam() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var retValMatches = false
        self.webView.callJavascript(name: "methodWithNoParam", args: []) { (result, error) -> () in
            let resultString = result as? String
            if let retVal = resultString {
                if retVal == "methodWithNoParam called." {
                    retValMatches = true
                }
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(retValMatches)
    }
    
    func testCallNonExistingMethod() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var retValMatches = false
        self.webView.callJavascript(name: "callMethodThatDoesntExist", args: []) { (result, error) -> () in
            if error!.localizedDescription == "A JavaScript exception occurred" {
                retValMatches = true
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(retValMatches)
    }
    
    func testCallMethodWithMultipleParams() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var retValMatches = false
        let boolParam = true
        let intParam = 999
        let optionalIntParam:Int? = nil
        let stringParam = "hello swift"
        let userDefinedTypeParam = UserDefinedType()
        self.webView.callJavascript(name: "methodWithMultipleParams", args: [boolParam, intParam, optionalIntParam, stringParam, userDefinedTypeParam]) { (result, error) -> () in
            let resultString = result as? String
            if let retVal = resultString {
                if retVal == "true, 999, null, hello swift, [object Object]" {
                    retValMatches = true
                }
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(retValMatches)
    }
    
    func testCallMethodOnAnObject() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var retValMatches = false
        self.webView.callJavascript(name: "testObject.getName", args: []) { (result, error) -> () in
            let resultString = result as? String
            if let retVal = resultString {
                if retVal == "veil" {
                    retValMatches = true
                }
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(retValMatches)
    }
    
    func testCallMethodExpectingNewline() {
        loadWebViewAndWait()
        let x = expectation(description: "js result")
        var retValMatches = false
        self.webView.callJavascript(name: "methodWithNoParam", args: ["hello \n"]) { (result, error) -> () in
            let resultString = result as? String
            if let retVal = resultString {
                if retVal == "methodWithNoParam called." {
                    retValMatches = true
                }
            }
            x.fulfill()
        }
        wait(for: [x], timeout: 5)
        XCTAssertTrue(retValMatches)
    }
}
