//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore

enum JSContextBridgeError: Error {
    case invalidContext
    case invalidFunction
    case promiseRejected
}

public class JSContextBridge: JSEvaluating {

    public init() {
        self.plugins = []
    }

    public func addPlugin<T: Plugin>(_ plugin: T) {
        plugins.append(plugin)
    }

    public func attach(to context: JSContext) {
        guard self.context == nil else {
            return
        }

        self.context = context
        let nimbusDeclaration = """
        __nimbus = {"plugins": {}};
        true;
        """
        context.evaluateScript(nimbusDeclaration)
        for plugin in plugins {
            let connection = JSContextConnection(from: context, bridge: self, as: plugin.namespace)
            plugin.bind(to: connection)
        }
    }

    public func invoke(
        _ identifierSegments: [String],
        with args: [Encodable] = [],
        callback: @escaping (Error?, JSValue?) -> Void
    ) {
        guard let context = context else {
            callback(JSContextBridgeError.invalidContext, nil)
            return
        }

        let promiseGlobal = context.globalObject.objectForKeyedSubscript("Promise")
        var functionValue: JSValue? = context.globalObject
        for segment in identifierSegments {
            functionValue = functionValue?.objectForKeyedSubscript(segment)
        }

        if let function = functionValue, function.isUndefined == true || functionValue == nil {
            callback(JSContextBridgeError.invalidFunction, nil)
            return
        }

        do {
            let jsArgs = try args.map { arg -> JSValue in
                return try arg.toJSValue(context: context)
            }
            let result = functionValue?.call(withArguments: jsArgs)
            let resolveArgs: [Any] = result != nil ? [result!] : []
            let reject: @convention(block) (JSValue) -> Void = { _ in
                let error = JSContextBridgeError.promiseRejected
                callback(error, nil)
            }

            let resolve: @convention(block) (JSValue) -> Void = { result in
                callback(nil, result)
            }
            var callbacks: [JSValue] = []
            if let jsResolve = JSValue(object: resolve, in: context) {
                callbacks.append(jsResolve)
            }
            if let jsReject = JSValue(object: reject, in: context) {
                callbacks.append(jsReject)
            }

            let promise = promiseGlobal?.invokeMethod("resolve", withArguments: resolveArgs)
            promise?.invokeMethod("then", withArguments: callbacks)
        } catch {
            callback(error, nil)
        }
    }

    public func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        invoke(identifierSegments, with: args) { (error, resultValue: JSValue?) in
            if let jsResult = resultValue, let result = decodeJSValue(jsResult, destinationType: R.self) {
                callback(nil, result)
            } else {
                callback(error, nil)
            }
        }
    }

    var plugins: [Plugin]
    var context: JSContext?
}
