//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import WebKit

/**
 A `WebViewBridge` links native functions to a `WKWebView` instance.

 Plugins attached to this instance can interact with javascript executing in the attached `WKWebView`.
 */
public class WebViewBridge: NSObject, JSEvaluating {
    public var plugins: [Plugin]

    init(webView: WKWebView, plugins: [Plugin]) {
        self.webView = webView
        self.plugins = plugins
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
    public func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        invoke(identifierSegments, with: args, callback: callback)
    }

    private let promisesQueue = DispatchQueue(label: "Nimbus.promisesQueue")
    typealias PromiseCallback = (Error?, Any?) -> Void
    private var promises: [String: PromiseCallback] = [:]
    weak var webView: WKWebView?
}

extension WebViewBridge: WKScriptMessageHandler {
    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        guard let method = body["method"] as? String else { return }

        switch method {
        case "resolvePromise":
            guard let promiseId = body["promiseId"] as? String else {
                return
            }
            var callback: PromiseCallback?
            promisesQueue.sync {
                callback = self.promises.removeValue(forKey: promiseId)
            }
            callback?(nil, body["value"])

        case "rejectPromise":
            guard let promiseId = body["promiseId"] as? String,
                let value = body["value"] as? String else {
                return
            }
            var callback: PromiseCallback?
            promisesQueue.sync {
                callback = self.promises.removeValue(forKey: promiseId)
            }
            callback?(PromiseError.message(value), nil)

        case "pageUnloaded":
            var callbacks: [String: PromiseCallback] = [:]
            promisesQueue.sync {
                callbacks = self.promises
                self.promises = [:]
            }
            callbacks.values.forEach { callback in callback(PromiseError.pageUnloaded, nil) }

        default:
            break
        }
    }
}

extension BridgeBuilder {
    static func attach(bridge: WebViewBridge, webView: WKWebView, plugins: [Plugin]) {
        let configuration = webView.configuration
        configuration.userContentController.add(bridge, name: "_nimbus")
        configuration.preferences.javaScriptEnabled = true
        #if DEBUG
            configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif

        for plugin in plugins {
            let connection = WebViewConnection(from: webView, bridge: bridge, as: plugin.namespace)
            plugin.bind(to: connection)
            if let script = connection.userScript() {
                let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                webView.configuration.userContentController.addUserScript(userScript)
            }
        }
    }
}

public enum PromiseError: Error, Equatable {
    case pageUnloaded
    case message(_ message: String)
}
