//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore

/**
 A `JSContextBridgeError` describes why a bridge function failed.
 */
enum JSContextBridgeError: Error {
    /**
     There was no `JSContext` instance available to perform the given operation with.
     */
    case invalidContext
    /**
     The javascript function attempting to be called did not exist or was not a function.
     */
    case invalidFunction
    /**
     The promise returned by the javascript function being called ended in a rejected state.
     */
    case promiseRejected
}

/**
 A `JSContextBridge` links native functions to a `JSContext` instance.

 Plugins attached to this instance can interact with javascript executing in the attached `JSContext`.
 */
public class JSContextBridge: NSObject, JSEvaluating {
    var plugins: [Plugin]
    
    init(context: JSContext?, plugins: [Plugin]) {
        self.context = context
        self.plugins = plugins
    }

    func invoke(
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
                try arg.toJSValue(context: context)
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

    /**
     The implementation of the `JSEvaluating` protocol.

     The function described by the identifierPath is called with the given arguments and the result is passed to the given callback.
     */
    public func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        invoke(identifierSegments, with: args) { (error, resultValue: JSValue?) in
            if
                let jsResult = resultValue,
                let result = try? JSValueDecoder().decode(R.self, from: jsResult) {
                callback(nil, result)
            } else {
                callback(error, nil)
            }
        }
    }

    var context: JSContext?
}

extension BridgeBuilder {
    static func attach(bridge: JSContextBridge, context: JSContext, plugins: [Plugin]) {
        let nimbusDeclaration = """
            __nimbus = {"plugins": {}};
            true;
            """
        context.evaluateScript(nimbusDeclaration)
        
        for plugin in plugins {
            let connection = JSContextConnection(from: context, bridge: bridge, as: plugin.namespace)
            plugin.bind(to: connection)
        }
    }
}
