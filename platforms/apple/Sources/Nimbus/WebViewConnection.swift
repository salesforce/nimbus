//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 A `Connection` links a web view to native functions.

 Each connection can bind multiple functions and expose them under
 a single namespace in JavaScript.
 */
public class WebViewConnection: Connection {

    /**
     Create a connection from the web view to an object.
     */
    public init(from webView: WKWebView, bridge: Bridge, as namespace: String) {
        self.webView = webView
        self.namespace = namespace
        self.bridge = bridge
        let messageHandler = ConnectionMessageHandler(connection: self)
        webView.configuration.userContentController.add(messageHandler, name: namespace)
    }

    /**
     Non-generic inner class that can be set as a WKScriptMessageHandler (requires @objc).

     The `WKUserContentController` will retain the message handler, and the message
     handler will in turn retain the `Connection`.
     */
    private class ConnectionMessageHandler: NSObject, WKScriptMessageHandler {
        init(connection: WebViewConnection) {
            self.connection = connection
        }

        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            guard
                let params = message.body as? NSDictionary,
                let method = params["method"] as? String,
                let args = params["args"] as? [Any],
                let promiseId = params["promiseId"] as? String
            else {
                return
            }

            connection.call(method, args: args, promise: promiseId)
        }

        let connection: WebViewConnection
    }

    /**
     Bind the callable object to a function `name` under this conenctions namespace.
     */
    public func bind(_ callable: Callable, as name: String) {
        bindings[name] = callable
        let stubScript = """
        __nimbusPluginExports = window.__nimbusPluginExports || {};
        (function(){
          let exports = __nimbusPluginExports["\(namespace)"];
          if (exports === undefined) {
            exports = [];
            __nimbusPluginExports["\(namespace)"] = exports;
          }
          exports.push("\(name)");
        }());
        true;
        """

        let script = WKUserScript(source: stubScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(script)
    }

    public func invoke<R: Decodable>(_ identifierPath: String, with args: Encodable..., callback: @escaping (Error?, R?) -> Void) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        bridge?.invoke(identifierSegments, with: args, callback: callback)
    }

    /**
     Called by the ConnectionMessageHandler when JS in the webview invokes a function of a native extension..
     */
    public func call(_ method: String, args: [Any], promise: String) {
        if let callable = bindings[method] {
            do {
                // walk args, converting callbacks into Callables
                let args = args.map { arg -> Any in
                    switch arg {
                    case let dict as NSDictionary:
                        if let callbackId = dict["callbackId"] as? String {
                            return Callback(webView: webView!, callbackId: callbackId)
                        } else {
                            print("non-callback dictionary")
                        }
                    default:
                        break
                    }
                    return arg
                }

                // The `callable` here is the generated Callable* struct instantiated when bind() was called.
                // `args` can be both regular params or `Callback`s which are themselves `Callable`s
                let rawResult = try callable.call(args: args)
                var result: EncodableValue
                if type(of: rawResult) == Void.self {
                    result = .void
                } else if let encodable = rawResult as? Encodable {
                    result = .value(encodable)
                } else {
                    throw ParameterError.conversion
                }
                resolvePromise(promiseId: promise, result: result)
            } catch {
                rejectPromise(promiseId: promise, error: error)
            }
        }
    }

    private func resolvePromise(promiseId: String, result: Any) {
        let resultString: String
        switch result {
        case is ():
            resultString = "undefined"
        case let value as EncodableValue:
            // swiftlint:disable:next force_try
            resultString = try! String(data: JSONEncoder().encode(value), encoding: .utf8)!
        default:
            fatalError("Unsupported return type \(type(of: result))")
        }
        webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', \(resultString).v);")
    }

    private func rejectPromise(promiseId: String, error: Error) {
        webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', undefined, '\(error)');")
    }

    private let namespace: String
    private weak var webView: WKWebView?
    private weak var bridge: Bridge?
    private var bindings: [String: Callable] = [:]
}
