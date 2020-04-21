//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit
import XCTest
@testable import NimbusJS

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
