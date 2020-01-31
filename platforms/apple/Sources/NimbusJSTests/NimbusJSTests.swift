//
//  NimbusJSTests.swift
//  NimbusJSTests
//
//  Created by Paul Tiarks on 1/31/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import XCTest
@testable import NimbusJS
import WebKit

class NimbusJSTests: XCTestCase {

    func testInjectingJS() {
        let webView = WKWebView()
        let testBundle = Bundle(for: type(of: self))
        let userContentController = webView.configuration.userContentController
        XCTAssertEqual(userContentController.userScripts.count, 0)
        XCTAssertNoThrow(try webView.injectNimbusJavascript(scriptName: "testJSSource", bundle: testBundle))
        XCTAssertEqual(userContentController.userScripts.count, 1)
    }

    func testInjectionFailure() {
        let webView = WKWebView()
        let testBundle = Bundle(for: type(of: self))
        XCTAssertThrowsError(try webView.injectNimbusJavascript(scriptName: "nonexistentscript", bundle: testBundle))
    }

}
