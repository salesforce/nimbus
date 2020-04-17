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
}

public class JSContextBridge {

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
            let connection = JSContextConnection(from: context, as: plugin.namespace)
            plugin.bind(to: connection)
        }
    }

    public func invoke(
        _ identifierSegments: [String],
        with args: [Encodable],
        callback: @escaping (Error?, JSValue?) -> Void
    ) {
        guard let context = context else {
            callback(JSContextBridgeError.invalidContext, nil)
            return
        }

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
            callback(nil, result)
        } catch {
            callback(error, nil)
        }
    }

    public func invoke(
        _ identifierPath: String,
        with args: Encodable...,
        callback: @escaping (Error?, JSValue?) -> Void
    ) {
        let identifierSegments = identifierPath.split(separator: ".").map(String.init)
        invoke(identifierSegments, with: args, callback: callback)
    }

    var plugins: [Plugin]
    var context: JSContext?
}
