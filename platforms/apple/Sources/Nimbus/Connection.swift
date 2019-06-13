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
public class Connection<C>: Binder {
    public typealias Target = C

    /**
     Create a connection from the web view to an object.
     */
    init(from webView: WKWebView, to target: C, as namespace: String) {
        self.webView = webView
        self.target = target
        self.namespace = namespace
        let messageHandler = ConnectionMessageHandler(connection: self)
        webView.configuration.userContentController.add(messageHandler, name: namespace)
    }

    /**
     Non-generic inner class that can be set as a WKScriptMessageHandler (requires @objc).

     The `WKUserContentController` will retain the message handler, and the message
     handler will in turn retain the `Connection`.
     */
    private class ConnectionMessageHandler: NSObject, WKScriptMessageHandler {
        init(connection: Connection) {
            self.connection = connection
        }

        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            guard
                let params = message.body as? NSDictionary,
                let method = params["method"] as? String,
                let args = params["args"] as? [Any],
                let promiseId = params["promiseId"] as? String else {
                return
            }

            connection.call(method, args: args, promise: promiseId)
        }

        let connection: Connection
    }

    /**
     Bind the callable object to a function `name` under this conenctions namespace.
     */
    public func bind(_ callable: Callable, as name: String) {
        bindings[name] = callable
        let stubScript = """
        \(namespace) = window.\(namespace) || {};
        \(namespace).\(name) = function() {
            let functionArgs = nimbus.cloneArguments(arguments);
            return new Promise(function(resolve, reject) {
                var promiseId = nimbus.uuidv4();
                nimbus.promises[promiseId] = {resolve, reject};

                window.webkit.messageHandlers.\(namespace).postMessage({
                    method: '\(name)',
                    args: functionArgs,
                    promiseId: promiseId
                });
            });
        };
        true;
        """

        let script = WKUserScript(source: stubScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(script)
    }

    func call(_ method: String, args: [Any], promise: String) {
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
                let rawResult = try callable.call(args: args)
                var result: EncodableValue
                if type(of: rawResult) == Void.self {
                    result = .void
                } else if let encodable = rawResult as? Encodable {
                    result = .value(encodable)
                } else {
                    throw ParameterError()
                }

                resolvePromise(promiseId: promise, result: result)
            } catch {
                rejectPromise(promiseId: promise, error: error)
            }
        }
    }

    private func resolvePromise(promiseId: String, result: Any) {
        var resultString = ""
        switch result {
        case is ():
            resultString = "undefined"

        case let value as EncodableValue:
            // swiftlint:disable:next force_try
            resultString = try! String(data: JSONEncoder().encode(value), encoding: .utf8)!

        default:
            fatalError("Unsupported return type \(type(of: result))")
        }
        webView?.evaluateJavaScript("nimbus.resolvePromise('\(promiseId)', \(resultString).v);")
    }

    private func rejectPromise(promiseId: String, error: Error) {
        webView?.evaluateJavaScript("nimbus.resolvePromise('\(promiseId)', undefined, '\(error)');")
    }

    public let target: C
    private let namespace: String
    private weak var webView: WKWebView?
    private var bindings: [String: Callable] = [:]
}
