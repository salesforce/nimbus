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
public class Connection<C> {

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
    private class ConnectionMessageHandler : NSObject, WKScriptMessageHandler {
        init(connection: Connection) {
            self.connection = connection
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
    func bind(_ callable: Callable, as name: String) {
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

        let script = WKUserScript(source: stubScript, injectionTime: .atDocumentStart, forMainFrameOnly:false)
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
                let result = try callable.call(args: args)
                resolvePromise(id: promise, result: result)
            } catch {
                rejectPromise(id: promise, error: error)
            }
        }
    }

    private func resolvePromise(id: String, result: Any) {
        var resultString = ""
        switch(result) {
        case is Void:
            resultString = "undefined"

        case let value as EncodableValue:
            // swiftlint:disable:next force_try
            resultString = try! String(data: JSONEncoder().encode(value), encoding: .utf8)!

        default:
            fatalError("Unsupported return type \(type(of:result))")
        }
        webView?.evaluateJavaScript("nimbus.resolvePromise('\(id)', \(resultString).v);")
    }

    private func rejectPromise(id: String, error: Error) {
        webView?.evaluateJavaScript("nimbus.resolvePromise('\(id)', undefined, '\(error)');")
    }

    private let target: C
    private let namespace: String
    private weak var webView: WKWebView?
    private var bindings: [String:Callable] = [:]

}

// Bindings for supported method arity
extension Connection {

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable>(_ function: @escaping (C) -> () -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { () -> EncodableValue in
            let result = boundFunction()
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind(_ function: @escaping (C) -> () -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { () -> EncodableValue in
            boundFunction()
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0>(_ function: @escaping (C) -> (A0) -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0) -> EncodableValue in
            let result = boundFunction(a0)
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (C) -> (A0) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0) -> EncodableValue in
            boundFunction(a0)
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CB0: Encodable>(_ function: @escaping (C) -> ((CB0) -> ()) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> EncodableValue in
            boundFunction() { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1>(_ function: @escaping (C) -> (A0, A1) -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1) -> EncodableValue in
            let result = boundFunction(a0, a1)
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (C) -> (A0, A1) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1) -> EncodableValue in
            boundFunction(a0, a1)
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0: Encodable>(_ function: @escaping (C) -> (A0, @escaping (CB0) -> ()) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> EncodableValue in
            boundFunction(arg0) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2>(_ function: @escaping (C) -> (A0, A1, A2) -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2) -> EncodableValue in
            let result = boundFunction(a0, a1, a2)
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (C) -> (A0, A1, A2) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2) -> EncodableValue in
            boundFunction(a0, a1, a2)
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0: Encodable>(_ function: @escaping (C) -> (A0, A1, @escaping (CB0) -> ()) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, callable: Callable) -> EncodableValue in
            boundFunction(a0, a1) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3>(_ function: @escaping (C) -> (A0, A1, A2, A3) -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, a3: A3) -> EncodableValue in
            let result = boundFunction(a0, a1, a2, a3)
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (C) -> (A0, A1, A2, A3) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, a3: A3) -> EncodableValue in
            boundFunction(a0, a1, a2, a3)
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0: Encodable>(_ function: @escaping (C) -> (A0, A1, A2, @escaping (CB0) -> ()) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, callable: Callable) -> EncodableValue in
            boundFunction(a0, a1, a2) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3, A4>(_ function: @escaping (C) -> (A0, A1, A2, A3, A4) -> R, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, a3: A3, a4: A4) -> EncodableValue in
            let result = boundFunction(a0, a1, a2, a3, a4)
            return .value(result)
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, A4>(_ function: @escaping (C) -> (A0, A1, A2, A3, A4) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, a3: A3, a4: A4) -> EncodableValue in
            boundFunction(a0, a1, a2, a3, a4)
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable>(_ function: @escaping (C) -> (A0, A1, A2, A3, @escaping (CB0) -> ()) -> (), as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (a0: A0, a1: A1, a2: A2, a3: A3, callable: Callable) -> EncodableValue in
            boundFunction(a0, a1, a2, a3) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
            return .void
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

}
