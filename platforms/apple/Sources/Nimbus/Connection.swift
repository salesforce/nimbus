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
                let promiseId = params["promiseId"] as? String,
                let promisifyCallback = params["promisifyCallback"] as? Bool else {
                return
            }

            connection.call(method, args: args, promise: promiseId, promisifyCallback: promisifyCallback)
        }

        let connection: Connection
    }

    /**
     Bind the callable object to a function `name` under this conenctions namespace.
     */
    public func bind(_ callable: Callable, as name: String, trailingClosure: TrailingClosure) {
        bindings[name] = callable
        var forPromisifiedClosure = "false"
        if case TrailingClosure.promise = trailingClosure {
            forPromisifiedClosure = "true"
        }
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
                    promiseId: promiseId,
                    promisifyCallback: \(forPromisifiedClosure)
                });
            });
        };
        true;
        """

        let script = WKUserScript(source: stubScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(script)
    }

    func call(_ method: String, args: [Any], promise: String, promisifyCallback: Bool) {
        if let callable = bindings[method] {
            do {
                // walk args, converting callbacks into Callables
                var args = args.map { arg -> Any in
                    switch arg {
                    case let dict as NSDictionary:
                        if let callbackId = dict["callbackId"] as? String {
                            if promisifyCallback {
                                fatalError("Trailing closure that is promsified can not have callback ID")
                            } else {
                                return Callback(webView: webView!, callbackId: callbackId)
                            }
                        } else {
                            print("non-callback dictionary")
                        }
                    default:
                        break
                    }
                    return arg
                }
                if promisifyCallback {
                    args.append(Callback(webView: webView!, callbackId: promise))
                }
                let rawResult = try callable.call(args: args, forPromisifiedClosure: promisifyCallback)
                if !promisifyCallback {
                    if rawResult is NSArray || rawResult is NSDictionary {
                        webView?.resolvePromise(promiseId: promise, result: rawResult)
                    } else {
                        var result: EncodableValue
                        if type(of: rawResult) == Void.self {
                            result = .void
                        } else if let encodable = rawResult as? Encodable {
                            result = .value(encodable)
                        } else {
                            throw ParameterError.conversion
                        }
                        webView?.resolvePromise(promiseId: promise, result: result)
                    }
                }
            } catch {
                webView?.rejectPromise(promiseId: promise, error: error)
            }
        }
    }

    public let target: C
    private let namespace: String
    private weak var webView: WKWebView?
    private var bindings: [String: Callable] = [:]
}
