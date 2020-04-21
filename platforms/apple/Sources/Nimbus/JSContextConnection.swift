//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextConnection: Connection {

    init(from context: JSContext, bridge: JSInvokable, as namespace: String) {
        self.context = context
        self.bridge = bridge
        self.namespace = namespace
        self.promiseGlobal = context.objectForKeyedSubscript("Promise")
        let plugins = context.objectForKeyedSubscript("__nimbus")?.objectForKeyedSubscript("plugins")
        var connection = plugins?.objectForKeyedSubscript(namespace)
        if connection?.isUndefined == true {
            connection = JSValue.init(newObjectIn: context)
            plugins?.setObject(connection, forKeyedSubscript: namespace)
        }
        self.connectionValue = connection
    }

    public func bind(_ callable: Callable, as name: String) {
        guard let context = self.context else {
            return
        }
        let binding: @convention(block) () -> Any? = {
            let args: [Any] = JSContext.currentArguments() ?? []
            let mappedArgs = args.map { arg -> Any in
                if let jsArg = arg as? JSValue, jsArg.isFunction() {
                    return JSValueCallback(callback: jsArg)
                }
                return arg
            }
            do {
                var resultArguments: [Any] = []
                let rawResult = try callable.call(args: mappedArgs)
                if type(of: rawResult) as? Encodable.Type != nil {
                    let encodableResult = rawResult as! Encodable // swiftlint:disable:this force_cast
                    resultArguments.append(try encodableResult.toJSValue(context: context))
                } else if type(of: rawResult) != Void.self {
                    throw ParameterError.conversion
                }
                return self.promiseGlobal?.invokeMethod("resolve", withArguments: resultArguments)
            } catch {
                return self.promiseGlobal?.invokeMethod("reject", withArguments: [])
            }
        }

        connectionValue?.setObject(binding, forKeyedSubscript: name)
    }

    public func invoke<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        bridge?.invoke(identifierPath, with: args, callback: callback)
    }

    private let namespace: String
    private weak var context: JSContext?
    private var bridge: JSInvokable?
    private let promiseGlobal: JSValue?
    private let connectionValue: JSValue?
}

extension Encodable {
    func toJSValue(context: JSContext) throws -> JSValue {
        return try JSValueEncoder().encode(self, context: context)
    }
}

extension JSValue {
    func isFunction() -> Bool {
        let functionType = self.context.globalObject.objectForKeyedSubscript("Function")
        return self.isInstance(of: functionType)
    }
}
