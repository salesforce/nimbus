//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import WebKit

/**
 A `WebViewConnection` links a web view to native functions.

 Each connection can bind multiple functions and expose them under
 a single namespace in JavaScript.
 */
public class WebViewConnection: Connection, CallableBinder {
    /**
     Create a connection from the web view to an object.
     */
    public init(from webView: WKWebView, bridge: JSEvaluating, as namespace: String) {
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
    func bindCallable(_ name: String, to callable: @escaping Callable) {
        bindings[name] = callable
        scriptParts.append(name)
    }

    func decode<T: Decodable>(_ value: Any?, as type: T.Type) -> Result<T, Error> {
        var data = value as? Data
        if data == nil,
            let string = value as? String {
            data = string.data(using: .utf8)
        }
        if let data = data {
            do {
                let value = try JSONDecoder().decode(type, from: data)
                return .success(value)
            } catch {
                if let decodingError = error as? DecodingError {
                    // This is a special case we need to catch&handle where the input is a string that
                    // contains JSON but not of a particular user defined data type.
                    if case .typeMismatch(let incomingType, let context) = decodingError {
                        if incomingType is String.Type &&
                            context.debugDescription == "Expected to decode String but found a dictionary instead." {
                            return .failure(error)
                        }
                    }
                    if #available(iOS 13, macOS 10.15, *) {
                        // Another special case to handle where the input is null.
                        if case .valueNotFound = decodingError {
                            return .failure(error)
                        }
                    } else {
                        if let value = value {
                            let valueStringified = "\(value)"

                            // Special case to handle where the input is null, for iOS 12 and below.
                            if valueStringified == "null" {
                                if case .dataCorrupted = decodingError {
                                    return .failure(error)
                                }
                            }
                        }
                    }
                }
            }
        }
        if let value = value as? T {
            return .success(value)
        }
        return .failure(DecodeError())
    }

    func encode<T: Encodable>(_ value: T) -> Result<Any?, Error> {
        if #available(iOS 13, macOS 10.15, *) {
            // iOS 13+ and macOS 10.15+ handle encoding non-container values at the top-level
            return Result {
                let data = try JSONEncoder().encode(value)
                return String(data: data, encoding: .utf8)
            }
        } else {
            // on iOS 12 and below, we need to wrap the encodable to ensure the top-level is a container
            let encodableValue: EncodableValue = .value(value)
            return Result {
                let data = try JSONEncoder().encode(encodableValue)
                return String(data: data, encoding: .utf8)
            }
        }
    }

    func encode(_ value: Encodable) -> Result<Any?, Error> {
        if #available(iOS 13, macOS 10.15, *) {
            return Result {
                try value.toJSONValue()
            }
        } else {
            let encodableValue: EncodableValue = .value(value)
            return Result {
                try encodableValue.toJSONValue()
            }
        }
    }

    func callback<T: Encodable>(from value: Any?, taking argType: T.Type) -> Result<(T) -> Void, Error> {
        guard
            let callbackId = value as? String,
            let webView = self.webView
        else {
            return .failure(DecodeError())
        }
        let callback = WebViewCallback(webView: webView, callbackId: callbackId)
        return .success({ [weak self] (value: T) in
            guard let self = self else { return }
            guard let result = try? self.encode(value).get() as Any else { return }
            _ = try? callback.call(args: [result])
        })
    }

    func callbackEncodable(from value: Any?) -> Result<(Encodable) -> Void, Error> {
        guard
            let callbackId = value as? String,
            let webView = self.webView
        else {
            return .failure(DecodeError())
        }
        let callback = WebViewCallback(webView: webView, callbackId: callbackId)
        return .success({ (value: Encodable) in
            guard let result = try? self.encode(value).get() as Any else { return }
            _ = try? callback.call(args: [result])
        })
    }

    func callback<T: Encodable, U: Encodable>(from value: Any?, taking argType: (T.Type, U.Type)) -> Result<(T, U) -> Void, Error> {
        guard
            let callbackId = value as? String,
            let webView = self.webView
        else {
            return .failure(DecodeError())
        }
        let callback = WebViewCallback(webView: webView, callbackId: callbackId)
        return .success({ [weak self] (value0: T, value1: U) in
            guard let self = self else { return }
            guard let result0 = try? self.encode(value0).get() as Any else { return }
            guard let result1 = try? self.encode(value1).get() as Any else { return }
            _ = try? callback.call(args: [result0, result1])
        })
    }

    public func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        bridge?.evaluate(identifierPath, with: args, callback: callback)
    }

    /**
     Called by the ConnectionMessageHandler when JS in the webview invokes a function of a native extension..
     */
    public func call(_ method: String, args: [Any], promise: String) {
        if let callable = bindings[method] {
            do {
                let rawResult = try callable(args)
                try resolvePromise(promiseId: promise, result: rawResult)
            } catch {
                rejectPromise(promiseId: promise, error: error)
            }
        }
    }

    private func resolvePromise(promiseId: String, result: Any?) throws {
        if #available(iOS 13, macOS 10.15, *) {
            let resultString: String
            switch result {
            case is Void:
                resultString = "undefined"
            case let value as String:
                resultString = value
            default:
                throw ParameterError.conversion
            }
            webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', \(resultString));")
        } else {
            // on iOS 12 and below, the string will be an encoded `EncodableValue` so peek through and get just the value
            let resultString: String
            switch result {
            case is Void:
                resultString = "{v: undefined}"
            case let value as String:
                resultString = value
            default:
                throw ParameterError.conversion
            }
            webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', \(resultString).v);")
        }
    }

    private func rejectPromise(promiseId: String, error: Error) {
        switch error {
        case let encodableError as EncodableError:
            let error = EncodableValue.error(encodableError)
            if let data = try? JSONEncoder().encode(error),
                let jsonString = String(data: data, encoding: .utf8) {
                webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', undefined, \(jsonString).e);")
            } else {
                // if unable to decode then send then fallthrough to default error message
                fallthrough
            }
        default:
            webView?.evaluateJavaScript("__nimbus.resolvePromise('\(promiseId)', undefined, '\(error)');")
        }
    }

    func userScript() -> String? {
        guard !scriptParts.isEmpty else { return nil }
        let exports = scriptParts.map { name in
            "exports.push(\"\(name)\");"
        }.joined()
        let stubScript = """
        __nimbusPluginExports = window.__nimbusPluginExports || {};
        (function(){
          let exports = __nimbusPluginExports["\(namespace)"];
          if (exports === undefined) {
            exports = [];
            __nimbusPluginExports["\(namespace)"] = exports;
          }
        \(exports)
        }());
        true;
        """
        return stubScript
    }

    private let namespace: String
    private weak var webView: WKWebView?
    private var bridge: JSEvaluating?
    private var bindings: [String: Callable] = [:]
    private var scriptParts: [String] = []
}

extension Encodable {
    func toJSONValue() throws -> Any? {
        return try String(data: JSONEncoder().encode(self), encoding: .utf8)
    }
}
