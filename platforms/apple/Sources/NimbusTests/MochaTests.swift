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
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

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

    func testExecutePromiseResolved() {
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

        loadWebViewAndWait()

        let expected = expectation(description: "addOne")
        var err: Error?
        var result: Int?
        callbackTestExtension.addOne(5) {
            err = $0
            result = $1
            expected.fulfill()
        }

        wait(for: [expected], timeout: 30)
        XCTAssertNil(err)
        XCTAssertEqual(6, result)
    }

    func testExecutePromiseRejected() {
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

        loadWebViewAndWait()

        let expected = expectation(description: "failWith")
        var err: Error?
        var result: Double?
        callbackTestExtension.failWith(message: "epic fail") {
            err = $0
            result = $1
            expected.fulfill()
        }

        wait(for: [expected], timeout: 30)
        XCTAssertNotNil(err)
        XCTAssertNil(result)
    }

    func testPromiseRejectedOnRefresh() {
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

        loadWebViewAndWait()

        let expected = expectation(description: "wait")
        var err: Error?
        callbackTestExtension.wait(milliseconds: 60000) { error, _ in
            err = error
            expected.fulfill()
        }

        webView.reload()

        wait(for: [expected], timeout: 30)
        XCTAssertEqual(PromiseError.pageUnloaded, err as? PromiseError)
    }

    func testPromiseResolvingToVoid() {
        let callbackTestExtension = CallbackTestExtension()
        callbackTestExtension.bindToWebView(webView: webView)

        loadWebViewAndWait()

        let expected = expectation(description: "wait")
        var err: Error? = PromiseError.message("not called yet")
        callbackTestExtension.wait(milliseconds: 10) { error, _ in
            err = error
            expected.fulfill()
        }

        wait(for: [expected], timeout: 30)
        XCTAssertNil(err)
    }
}

public class CallbackTestExtension {
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

    func addOne(_ num: Int, promiseCompletion: @escaping (Error?, Int?) -> Void) {
        connection?.invoke("addOne", with: num, promiseCompletion: promiseCompletion)
    }

    func failWith(message: String, promiseCompletion: @escaping (Error?, Double?) -> Void) {
        connection?.invoke("failWith", with: message, promiseCompletion: promiseCompletion)
    }

    func wait(milliseconds: Int, promiseCompletion: @escaping (Error?, Void?) -> Void) {
        connection?.invoke("wait", with: milliseconds, promiseCompletion: promiseCompletion)
    }

    weak var connection: WebBinder?
}

extension CallbackTestExtension: NimbusExtension {
    public func bindToWebView(webView: WKWebView) {
        let connection = webView.addConnection(to: self, as: "callbackTestExtension")
        connection.bind(CallbackTestExtension.callbackWithSingleParam, as: "callbackWithSingleParam")
        connection.bind(CallbackTestExtension.callbackWithTwoParams, as: "callbackWithTwoParams")
        connection.bind(CallbackTestExtension.callbackWithSinglePrimitiveParam, as: "callbackWithSinglePrimitiveParam")
        connection.bind(CallbackTestExtension.callbackWithTwoPrimitiveParams, as: "callbackWithTwoPrimitiveParams")
        connection.bind(CallbackTestExtension.callbackWithPrimitiveAndUddtParams, as: "callbackWithPrimitiveAndUddtParams")
        self.connection = connection
    }
}
