---
layout: docs
---
# Plugin Testing Best Practices

Testing your Nimbus plugins, like all code, is important. Since plugins should, ideally, be well contained and singel responsibility, this makes them ideal for good unit testing. Since Nimbus is simply binding existing functions to a webview, plugin business logic can be tested independently with `XCTest` and don't, necessarily, need to be tested over the Nimbus bridge.

The focus of your testing across the Nimbus bridge should be on verifying the shape of parameters and return values, which will be serialized to json automatically by Nimbus. Combining that with other tests verifying business logic should give your plugins good coverage.

This guide will give an example of two kinds of testing strategies. One uses `XCTest` and a purpose-built Nimbus plugin to relay results to your code from the webview. The second uses Mocha, a javascript testing library, to perform assertions in the webview.

# XCTest

The basic strategy for testing with `XCTest` is as follows:
1. Prepare a Nimbus Bridge
    - Load the plugin you wish to test
    - Load a shim plugin that you can use to receive test results
2. Prepare a `WKWebView` instance with nimbus js
3. Attach the prepared Nimbus Bridge to the prepared `WKWebView` instance
4. Execute javascript in the `WKWebView` instance to call the plugin you wish to test and then redirect its results to your shim plugin
5. Wait for the result and assert all values are expected

Steps 1 through 3 are common and generic enough that they may be useful to extract into a convenience method or subclass of `XCTestCase`. Then each of your individual tests can focus on Step 4 and 5, which will be unique to each test. Your test case classes would look similar to the below:

```swift
class DharmaPluginTests: NimbusPluginTestsBase {
    var plugin = DharmaPlugin()

    override func setUp() {
        super.setUp()
        plugin = DharmaPlugin()
        nimbus.addExtension(plugin)
        loadWebViewAndWait()
    }

    func testTheNumbers() {
        let jsExpectation = expectation(description: "js")
        testBridge.currentExpectation = jsExpectation
        let js = """
                dharmaPlugin.theNumbers().then(function(result) {
                        testBridge.receiveResult(result);
                    });
                """
        webView.evaluateJavaScript(js) { _, _ in}
        wait(for: [jsExpectation], timeout: 5)
        if let currentResult = testBridge.currentResult as? [Int] {
            XCTAssertEqual(currentResult, [4, 8, 15, 16, 23, 42])
        } else {
            XCTFail()
        }
    }
}
```

Here is an example of a shim plugin implementation:
```swift
class NimbusTestBridge: NimbusExtension {
    var currentExpectation: XCTestExpectation?
    var currentResult: Any?

    func receiveResult(result: Any) {
        currentResult = result
        currentExpectation?.fulfill()
    }

    func bindToWebView(webView: WKWebView) {
        let testConnection = webView.addConnection(to: self, as: "testBridge")
        testConnection.bind(NimbusTestBridge.receiveResult, as: "receiveResult")
    }
}
```

Combined with the following implementation of `NimbusPluginTestsBase`:

```swift
class NimbusPluginTestsBase: XCTestCase, WKNavigationDelegate {
    var nimbus = NimbusBridge()
    var testBridge = NimbusTestBridge()
    var webView: WKWebView!
    var loadingExpectation: XCTestExpectation?

    override func setUp() {
        nimbus = NimbusBridge()
        testBridge = NimbusTestBridge()
        nimbus.addExtension(testBridge)
        webView = WKWebView()
        webView.navigationDelegate = self
    }

    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
    }

    func loadWebViewAndWait() {
        guard let nimbusPath = Bundle.main.path(forResource: "nimbus", ofType: "js") else {
            XCTFail("couldn't find nimbus js")
            return
        }

        if let nimbusScript = try? String(contentsOfFile: nimbusPath) {
            let userScript = WKUserScript(source: nimbusScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
            nimbus.attach(to: webView)
        } else {
            XCTFail("unable to make nimbus js string")
        }

        let html = "<html><body></body></html>"
        loadingExpectation = expectation(description: "web view load")
        webView.loadHTMLString(html, baseURL: nil)
        wait(for: [loadingExpectation!], timeout: 10)
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingExpectation?.fulfill()
    }

}
```

This combination allows you to call any of the functions that your plugin publishes and allow them to do any sort of asynchronous work and then receive the result via the shim plugin implementation. This also allows you to keep the actual tests fairly succinct and easy to read. This is merely an example implementation and should/could be reduced or extended depending on your specific needs.

# Mocha