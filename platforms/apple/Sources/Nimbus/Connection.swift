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
            guard let params = message.body as? NSDictionary,
                let promiseId = params["promiseId"] as? String else { return }

            let errParam = unwrapNSNull(params["err"])
            let result = unwrapNSNull(params["result"])
            if errParam != nil || result != nil || params.count == 1 {
                var err = errParam as? Error
                if let errString = errParam as? String {
                    switch errString {
                    case "ERROR_PAGE_UNLOADED":
                        err = PromiseError.pageUnloaded
                    default:
                        err = PromiseError.message(errString)
                    }
                }
                handlePromiseCompletion(for: promiseId, err: err, result: result)
            } else {
                // JS-initiated call into native extension.
                guard let method = params["method"] as? String,
                    let args = params["args"] as? [Any] else { return }

                connection.call(method, args: args, promise: promiseId)
            }
        }

        func handlePromiseCompletion(for promiseId: String, err: Error?, result: Any?) {
            connection.promisesQueue.async { [weak self] in
                guard let connection = self?.connection else { return } // Ensure connection is still alive.
                if let completion = connection.promises.removeValue(forKey: promiseId) {
                    // A completion block is tracked for this Promise. Call that completion.
                    completion.call(err: err, result: result)
                }
            }
        }

        let connection: Connection
    }

    /**
     Invokes a Promise-returning Javascript function and call the specified promiseCompletion when that Promise resolves or rejects.
     */
    public func invoke<R>(_ functionName: String, with args: Encodable..., promiseCompletion: @escaping (Error?, R?) -> Void) {
        let promiseId = UUID().uuidString
        self.promisesQueue.sync {
            self.promises[promiseId] = CallablePromiseCompletion(promiseCompletion)
        }
        webView?.callJavascript(name: "__nimbus.callAwaiting", args: [namespace, functionName, promiseId] + args) { (errString, err) -> Void in
            var textError: Error?
            if let errString = errString as? String {
                textError = PromiseError.message(errString)
            }
            if let err = err ?? textError {
                promiseCompletion(err, nil)
                // Remove the completion block we just registered, due to the failure to create the Promise.
                self.promisesQueue.async { [weak self] in
                    self?.promises.removeValue(forKey: promiseId)
                }
            }
        }
    }

    /**
     Bind the callable object to a function `name` under this conenctions namespace.
     */
    public func bind(_ callable: Callable, as name: String) {
        bindings[name] = callable
        let stubScript = """
        if (window.__nimbus === undefined) {
            window.__nimbus = {};
        }
        if (window.__nimbus.plugins === undefined) {
            window.__nimbus.plugins = {};
        }
        if (window.__nimbus.plugins.\(namespace) === undefined) {
            window.__nimbus.plugins.\(namespace) = {};
        }
        \(namespace) = window.__nimbus.plugins.\(namespace);
        \(namespace).\(name) = function() {
            let functionArgs = __nimbus.cloneArguments(arguments);
            return new Promise(function(resolve, reject) {
                var promiseId = window.__nimbus.uuidv4();
                window.__nimbus.promises[promiseId] = {resolve, reject};

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

    /**
     Called by the ConnectionMessageHandler when JS in the webview invokes a function of a native extension..
     */
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

                // The `callable` here is the generated Callable* struct instantiated when bind() was called.
                // `args` can be both regular params or `Callback`s which are themselves `Callable`s
                let rawResult = try callable.call(args: args)
                if rawResult is NSArray || rawResult is NSDictionary {
                    resolvePromise(promiseId: promise, result: rawResult)
                } else {
                    var result: EncodableValue
                    if type(of: rawResult) == Void.self {
                        result = .void
                    } else if let encodable = rawResult as? Encodable {
                        result = .value(encodable)
                    } else {
                        throw ParameterError.conversion
                    }
                    resolvePromise(promiseId: promise, result: result)
                }
            } catch {
                rejectPromise(promiseId: promise, error: error)
            }
        }
    }

    private func resolvePromise(promiseId: String, result: Any) {
        var resultString = ""
        if result is NSArray || result is NSDictionary {
            // swiftlint:disable:next force_try
            let data = try! JSONSerialization.data(withJSONObject: result, options: [])
            resultString = String(data: data, encoding: String.Encoding.utf8)!
            webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', \(resultString));")
        } else {
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
    }

    private func rejectPromise(promiseId: String, error: Error) {
        webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', undefined, '\(error)');")
    }

    private static func unwrapNSNull(_ opt: Any?) -> Any? {
        if opt as? NSNull != nil { return nil }
        return opt
    }

    public let target: C
    private let namespace: String
    private weak var webView: WKWebView?
    private var bindings: [String: Callable] = [:]

    // Synchronous queue; all accesses of the `promises` dictionary include writes.
    private let promisesQueue = DispatchQueue(label: "Nimbus.promisesQueue")
    private var promises: [String: PromiseCompletion] = [:]
}

public enum PromiseError: Error, Equatable {
    case pageUnloaded
    case message(_ message: String)
}

protocol PromiseCompletion {
    func call(err: Error?, result: Any?)
}

struct CallablePromiseCompletion<R>: PromiseCompletion {
    typealias FunctionType = (Error?, R?) -> Void
    let function: FunctionType
    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(err: Error?, result: Any?) {
        guard err == nil else {
            function(err, nil)
            return
        }

        if R.self == Void.self {
            function(nil, nil)
        } else if let result = result as? R {
            function(nil, result)
        } else {
            function(PromiseError.message("Could not convert \(String(describing: result)) to \(R.self)"), nil)
        }
    }
}
