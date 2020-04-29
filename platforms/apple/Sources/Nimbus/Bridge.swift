//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import WebKit

public class Bridge: NSObject {
    public func addPlugin<T: Plugin>(_ plugin: T) {
        plugins.append(plugin)
    }

    public func attach(to webView: WKWebView) {
        guard self.webView == nil else {
            return
        }

        self.webView = webView
        let configuration = webView.configuration
        configuration.userContentController.add(self, name: "_nimbus")
        configuration.preferences.javaScriptEnabled = true
        #if DEBUG
            configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        for plugin in plugins {
            plugin.bind(to: webView, bridge: self)
        }
    }

    /**
     Invokes a Promise-returning Javascript function and call the specified
     promiseCompletion when that Promise resolves or rejects.
     */
    func invoke<R>( // swiftlint:disable:this function_body_length
        _ identifierSegments: [String],
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        let promiseId = UUID().uuidString
        promisesQueue.sync {
            self.promises[promiseId] = { error, value in
                if error != nil {
                    callback(error, nil)
                } else {
                    if R.self == Void.self {
                        callback(nil, nil)
                    } else if let result = value as? R {
                        callback(nil, result)
                    } else {
                        callback(
                            PromiseError.message(
                                "Could not convert \(String(describing: value)) to \(R.self)"
                            ),
                            nil
                        )
                    }
                }
            }
        }

        let idSegmentString: String
        let argString: String
        do {
            let data = try JSONEncoder().encode(args.map(EncodableValue.value))
            argString = String(data: data, encoding: .utf8)!

            let idData = try JSONEncoder().encode(identifierSegments)
            idSegmentString = String(data: idData, encoding: .utf8)!
        } catch {
            return callback(error, nil)
        }

        let script = """
        {
            let idSegments = \(idSegmentString);
            let rawArgs = \(argString);
            let args = rawArgs.map(a => a.v);
            let promise = undefined;
            try {
                let fn = idSegments.reduce((state, key) => {
                    return state[key];
                }, window);
                promise = Promise.resolve(fn(...args));
            } catch (error) {
                promise = Promise.reject(error);
            }
            promise.then((value) => {
                webkit.messageHandlers._nimbus.postMessage({
                    method: "resolvePromise",
                    promiseId: "\(promiseId)",
                    value: value
                });
            }).catch((err) => {
                webkit.messageHandlers._nimbus.postMessage({
                    method: "rejectPromise",
                    promiseId: "\(promiseId)",
                    value: err.toString()
                });
            });
        }
        null;
        """

        webView?.evaluateJavaScript(script) { _, error in
            if let error = error {
                var callback: PromiseCallback?
                self.promisesQueue.sync {
                    callback = self.promises.removeValue(forKey: promiseId)
                }
                callback?(error, nil)
            }
        }
    }

    /**
     Invokes a Promise-returning Javascript function and call the specified
     promiseCompletion when that Promise resolves or rejects.
     */
    public func invoke<R>(
        _ identifierPath: String,
        with args: Encodable...,
        callback: @escaping (Error?, R?) -> Void
    ) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        invoke(identifierSegments, with: args, callback: callback)
    }

    var plugins: [Plugin] = []
    private let promisesQueue = DispatchQueue(label: "Nimbus.promisesQueue")
    typealias PromiseCallback = (Error?, Any?) -> Void
    private var promises: [String: PromiseCallback] = [:]
    weak var webView: WKWebView?
}

extension Bridge: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        guard let method = body["method"] as? String else { return }

        switch method {
        case "resolvePromise":
            guard let promiseId = body["promiseId"] as? String else {
                    return
            }
            var callback: PromiseCallback?
            self.promisesQueue.sync {
                callback = self.promises.removeValue(forKey: promiseId)
            }
            callback?(nil, body["value"])

        case "rejectPromise":
            guard let promiseId = body["promiseId"] as? String,
                let value = body["value"] as? String else {
                    return
            }
            var callback: PromiseCallback?
            self.promisesQueue.sync {
                callback = self.promises.removeValue(forKey: promiseId)
            }
            callback?(PromiseError.message(value), nil)

        case "pageUnloaded":
            var callbacks: [String: PromiseCallback] = [:]
            self.promisesQueue.sync {
                callbacks = self.promises
                self.promises = [:]
            }
            callbacks.values.forEach { callback in callback(PromiseError.pageUnloaded, nil) }

        default:
            break
        }
    }
}

public enum PromiseError: Error, Equatable {
    case pageUnloaded
    case message(_ message: String)
}
