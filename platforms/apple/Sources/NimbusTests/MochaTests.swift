//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Nimbus
import WebKit
import XCTest

class MochaTests: XCTestCase, WKNavigationDelegate {
    struct MochaMessage: Encodable {
        var stringField = "This is a string"
        var intField = 42
    }

    class MochaTestBridge {
        init(webView: WKWebView) {
            self.webView = webView
        }

        let webView: WKWebView
        let expectation = XCTestExpectation(description: "testsCompleted")
        var failures: Int = -1
        func testsCompleted(failures: Int) {
            self.failures = failures
            expectation.fulfill()
        }
        func onTestFail(testTitle: String, errMessage: String) {
            NSLog("[\(testTitle)] failed: \(errMessage)")
        }

        func ready() {}
        func sendMessage(name: String, includeParam: Bool) {
            if includeParam {
                webView.broadcastMessage(name: name, arg: MochaMessage())
            } else {
                webView.broadcastMessage(name: name)
            }
        }

    }

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

    func loadWebViewAndWait() {
        loadingExpectation = expectation(description: "web view loaded")
        loadingExpectation?.assertForOverFulfill = false
        if let url = Bundle(for: MochaTests.self).url(forResource: "index", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        wait(for: [loadingExpectation!], timeout: 5)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testExecuteMochaTests() {
        let testBridge = MochaTestBridge(webView: webView)
        let connection = webView.addConnection(to: testBridge, as: "mochaTestBridge")
        connection.bind(MochaTestBridge.testsCompleted, as: "testsCompleted")
        connection.bind(MochaTestBridge.ready, as: "ready")
        connection.bind(MochaTestBridge.sendMessage, as: "sendMessage")
        connection.bind(MochaTestBridge.onTestFail, as: "onTestFail")
        let callbackTestPlugin = CallbackTestPlugin()
        callbackTestPlugin.bind(to: webView, bridge: Bridge())

        loadWebViewAndWait()

        webView.evaluateJavaScript("""
            const titleFor = x => x.parent ? `${titleFor(x.parent)} ${x.title}` : x.title
            mocha.run(failures => { __nimbus.plugins.mochaTestBridge.testsCompleted(failures); })
                 .on('fail', (test, err) => __nimbus.plugins.mochaTestBridge.onTestFail(titleFor(test), err.message));
            true;
            """) { _, error in

            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [testBridge.expectation], timeout: 30)
        XCTAssertEqual(testBridge.failures, 0, "Mocha tests failed: \(testBridge.failures)")
    }
}

public class CallbackTestPlugin {
    func callbackWithSingleParam(completion: @escaping (MochaTests.MochaMessage) -> Swift.Void) {
        let mochaMessage = MochaTests.MochaMessage()
        completion(mochaMessage)
    }
    func callbackWithTwoParams(completion: @escaping (MochaTests.MochaMessage, MochaTests.MochaMessage) -> Swift.Void) {
        var mochaMessage = MochaTests.MochaMessage()
        mochaMessage.intField = 6
        mochaMessage.stringField = "int param is 6"
        completion(MochaTests.MochaMessage(), mochaMessage)
    }
    func callbackWithSinglePrimitiveParam(completion: @escaping (Int) -> Swift.Void) {
        completion(777)
    }
    func callbackWithTwoPrimitiveParams(completion: @escaping (Int, Int) -> Swift.Void) {
        completion(777, 888)
    }
    func callbackWithPrimitiveAndUddtParams(completion: @escaping (Int, MochaTests.MochaMessage) -> Swift.Void) {
        completion(777, MochaTests.MochaMessage())
    }

    func callbackWithSingleParamAndReturn(completion: @escaping (MochaTests.MochaMessage) -> Void) -> String {
        completion(.init())
        return "one"
    }

    func callbackWithSinglePrimitiveParamAndReturn(completion: @escaping (Int) -> Void) -> String {
        completion(1)
        return "one"
    }

    func callbackWithTwoParamAndReturn(completion: @escaping (MochaTests.MochaMessage, MochaTests.MochaMessage) -> Void) -> String {
        completion(.init(), .init(stringField: "mock", intField: 3))
        return "two"
    }

    func callbackWithTwoPrimitiveParamAndReturn(completion: @escaping (Int, Int) -> Void) -> String {
        completion(1, 2)
        return "two"
    }
}

extension CallbackTestPlugin: Plugin {
    public func bind(to webView: WKWebView, bridge: Bridge) {
        let connection = webView.addConnection(to: self, as: "callbackTestPlugin")
        connection.bind(CallbackTestPlugin.callbackWithSingleParam, as: "callbackWithSingleParam")
        connection.bind(CallbackTestPlugin.callbackWithTwoParams, as: "callbackWithTwoParams")
        connection.bind(CallbackTestPlugin.callbackWithSinglePrimitiveParam, as: "callbackWithSinglePrimitiveParam")
        connection.bind(CallbackTestPlugin.callbackWithTwoPrimitiveParams, as: "callbackWithTwoPrimitiveParams")
        connection.bind(CallbackTestPlugin.callbackWithPrimitiveAndUddtParams, as: "callbackWithPrimitiveAndUddtParams")
        connection.bind(CallbackTestPlugin.callbackWithSingleParamAndReturn, as: "callbackWithSingleParamAndReturn")
        connection.bind(CallbackTestPlugin.callbackWithSinglePrimitiveParamAndReturn, as: "callbackWithSinglePrimitiveParamAndReturn")
        connection.bind(CallbackTestPlugin.callbackWithTwoParamAndReturn, as: "callbackWithTwoParamAndReturn")
        connection.bind(CallbackTestPlugin.callbackWithTwoPrimitiveParamAndReturn, as: "callbackWithTwoPrimitiveParamAndReturn")
    }
}
