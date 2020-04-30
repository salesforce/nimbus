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

class MochaTests: XCTestCase, WKNavigationDelegate {
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
        if let path = Bundle(for: MochaTests.self).url(forResource: "nimbus", withExtension: "js", subdirectory: "iife"),
            let nimbus = try? String(contentsOf: path) {
            let userScript = WKUserScript(source: nimbus, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
        }
        if let url = Bundle(for: MochaTests.self).url(forResource: "index", withExtension: "html", subdirectory: "test-www") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            // when running from swiftpm, look for the file relative to the source root
            let basepath = URL(fileURLWithPath: #file)
            let url = URL(fileURLWithPath: "../../../../packages/test-www/dist/test-www/index.html", relativeTo: basepath)
            if FileManager().fileExists(atPath: url.absoluteURL.path) {
                webView.loadFileURL(url.absoluteURL, allowingReadAccessTo: url.absoluteURL)
            }
        }
        wait(for: [loadingExpectation!], timeout: 5)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

    func testExecuteMochaTests() {
        let testBridge = MochaTestBridge(webView: webView)
        let connection = WebViewConnection(from: webView, bridge: WebViewBridge(), as: "mochaTestBridge")
        connection.bind(testBridge.testsCompleted, as: "testsCompleted")
        connection.bind(testBridge.ready, as: "ready")
        connection.bind(testBridge.sendMessage, as: "sendMessage")
        connection.bind(testBridge.onTestFail, as: "onTestFail")
        let callbackTestPlugin = CallbackTestPlugin()
        let callbackConnection = WebViewConnection(from: webView, bridge: WebViewBridge(), as: callbackTestPlugin.namespace)
        callbackTestPlugin.bind(to: callbackConnection)

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

public class JSContextMochaTests: XCTestCase {
    var context: JSContext = JSContext()

    class JSContextMochaTestBridge {
        let context: JSContext
        let globals: JavaScriptCoreGlobalsProvider
        let expectation = XCTestExpectation(description: "testsCompleted")
        var failures: Int = -1

        init(context: JSContext) {
            self.context = context
            globals = JavaScriptCoreGlobalsProvider(context: context)
            let nimbusDeclaration = """
            __nimbus = {"plugins": {}};
            true;
            """
            context.evaluateScript(nimbusDeclaration)
        }

        func testsCompleted(failures: Int) {
            self.failures = failures
            expectation.fulfill()
        }

        func onTestFail(testTitle: String, errMessage: String) {
            NSLog("[\(testTitle)] failed: \(errMessage)")
        }

        func ready() {}
        func sendMessage(name: String, includeParam: Bool) {
            guard let broadcastFunc = context.globalObject.objectForKeyedSubscript("__nimbus")?.objectForKeyedSubscript("broadcastMessage") else {
                XCTFail("couldn't get a reference to broadcastMessage")
                return
            }
            if includeParam {
                let encodedMessage = try! JSValueEncoder().encode(MochaMessage(), context: context) // swiftlint:disable:this force_try
                broadcastFunc.call(withArguments: [name, encodedMessage])
            } else {
                broadcastFunc.call(withArguments: [name])
            }
        }
    }

    public override func setUp() {
        context = JSContext()
    }

    func evalScript(name: String, ext: String, subdirectory: String, context: JSContext) {
        if let path = Bundle(for: JSContextMochaTests.self).url(forResource: name, withExtension: ext, subdirectory: subdirectory),
            let script = try? String(contentsOf: path) {
            NSLog("eval-ing \(name).\(ext) from \(subdirectory) into context")
            context.evaluateScript(script)
        }
    }

    func loadContext() {
        // we might need to set something as 'global' before loading chai
        let global = context.globalObject
        context.setObject(global, forKeyedSubscript: "global" as NSString)
        context.evaluateScript("global.location = { \"search\": \"\" };")
        evalScript(name: "mocha", ext: "js", subdirectory: "test-www", context: context)
        context.evaluateScript("mocha.reporter('json'); mocha.setup('bdd');")
        evalScript(name: "chai", ext: "js", subdirectory: "test-www", context: context)
        evalScript(name: "bundle", ext: "js", subdirectory: "test-www", context: context)
    }

    func testExecuteMochaTests() {
        let testBridge = JSContextMochaTestBridge(context: context)
        let connection = JSContextConnection(from: context, bridge: JSContextBridge(), as: "mochaTestBridge")
        connection.bind(testBridge.testsCompleted, as: "testsCompleted")
        connection.bind(testBridge.ready, as: "ready")
        connection.bind(testBridge.sendMessage, as: "sendMessage")
        connection.bind(testBridge.onTestFail, as: "onTestFail")
        let callbackTestPlugin = CallbackTestPlugin()
        let callbackConnection = JSContextConnection(from: context, bridge: JSContextBridge(), as: callbackTestPlugin.namespace)
        callbackTestPlugin.bind(to: callbackConnection)

        loadContext()

        let testScript = """
        const titleFor = x => x.parent ? `${titleFor(x.parent)} ${x.title}` : x.title
        mocha.run(failures => { __nimbus.plugins.mochaTestBridge.testsCompleted(failures); })
             .on('fail', (test, err) => __nimbus.plugins.mochaTestBridge.onTestFail(titleFor(test), err.message));
        true;
        """

        let evalResult = context.evaluateScript(testScript)

        wait(for: [testBridge.expectation], timeout: 700)
        XCTAssertNotNil(evalResult, "test script failed to execute")
        XCTAssertEqual(testBridge.failures, 0, "Mocha tests failed: \(testBridge.failures)")
    }
}

struct MochaMessage: Encodable {
    var stringField = "This is a string"
    var intField = 42
}

public class CallbackTestPlugin {
    func callbackWithSingleParam(completion: @escaping (MochaMessage) -> Swift.Void) {
        let mochaMessage = MochaMessage()
        completion(mochaMessage)
    }

    func callbackWithTwoParams(completion: @escaping (MochaMessage, MochaMessage) -> Swift.Void) {
        var mochaMessage = MochaMessage()
        mochaMessage.intField = 6
        mochaMessage.stringField = "int param is 6"
        completion(MochaMessage(), mochaMessage)
    }

    func callbackWithSinglePrimitiveParam(completion: @escaping (Int) -> Swift.Void) {
        completion(777)
    }

    func callbackWithTwoPrimitiveParams(completion: @escaping (Int, Int) -> Swift.Void) {
        completion(777, 888)
    }

    func callbackWithPrimitiveAndUddtParams(completion: @escaping (Int, MochaMessage) -> Swift.Void) {
        completion(777, MochaMessage())
    }
}

extension CallbackTestPlugin: Plugin {
    public var namespace: String {
        return "callbackTestPlugin"
    }

    public func bind<C>(to connection: C) where C: Connection {
        connection.bind(callbackWithSingleParam, as: "callbackWithSingleParam")
        connection.bind(callbackWithTwoParams, as: "callbackWithTwoParams")
        connection.bind(callbackWithSinglePrimitiveParam, as: "callbackWithSinglePrimitiveParam")
        connection.bind(callbackWithTwoPrimitiveParams, as: "callbackWithTwoPrimitiveParams")
        connection.bind(callbackWithPrimitiveAndUddtParams, as: "callbackWithPrimitiveAndUddtParams")
    }
}
