//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

/**
 A `JSContextConnection` links a `JSContext` to native functions.

 Each connection can bind multiple functions and expose them under a single namespace in JavaScript.
 */
public class JSContextConnection: Connection, CallableBinder {
    /**
     Create a connection from the `JSContext` as the namespace.
     */
    init(from context: JSContext, bridge: JSEvaluating, as namespace: String) {
        self.context = context
        self.bridge = bridge
        self.namespace = namespace
        promiseGlobal = context.objectForKeyedSubscript("Promise")
        let plugins = context.objectForKeyedSubscript("__nimbus")?.objectForKeyedSubscript("plugins")
        var connection = plugins?.objectForKeyedSubscript(namespace)
        if connection?.isUndefined == true {
            connection = JSValue(newObjectIn: context)
            plugins?.setObject(connection, forKeyedSubscript: namespace)
        }
        connectionValue = connection
    }

    /**
     An implementation of the `Binder` protocol.

     Bind the callable in the namespace as the name.
     */
    func bindCallable(_ name: String, to callable: @escaping Callable) {
        let binding: @convention(block) () -> Any? = {
            let args: [Any] = JSContext.currentArguments() ?? []
            do {
                var resultArguments: [Any] = []
                let rawResult = try callable(args)
                switch rawResult {
                case let value as JSValue:
                    resultArguments = [value]
                case is Void:
                    break
                default:
                    throw ParameterError.conversion
                }
                return self.promiseGlobal?.invokeMethod("resolve", withArguments: resultArguments)
            } catch {
                // TODO: pass the error
                return self.promiseGlobal?.invokeMethod("reject", withArguments: [])
            }
        }

        connectionValue?.setObject(binding, forKeyedSubscript: name)
    }

    func decode<T: Decodable>(_ value: Any?, as type: T.Type) -> Result<T, Error> {
        guard let value = value as? JSValue else {
            return .failure(DecodeError())
        }
        return Result {
            try JSValueDecoder().decode(type, from: value)
        }
    }

    func encode<T: Encodable>(_ value: T) -> Result<Any?, Error> {
        guard let context = self.context else {
            return .failure(EncodeError())
        }
        return Result {
            try JSValueEncoder().encode(value, context: context)
        }
    }

    func callback<T: Encodable>(from value: Any?, taking argType: T.Type) -> Result<(T) -> Void, Error> {
        guard let callbackFunction = value as? JSValue else {
            return .failure(DecodeError())
        }
        let callback = JSValueCallback(callback: callbackFunction)
        return .success({ [weak self] (value: T) in
            guard let self = self else { return } // TODO: throw
            guard let result = try? self.encode(value).get() as Any else { return }
            try? callback.call(args: [result])
        })
    }

    func callback<T: Encodable, U: Encodable>(from value: Any?, taking argType: (T.Type, U.Type)) -> Result<(T, U) -> Void, Error> {
        guard let callbackFunction = value as? JSValue else {
            return .failure(DecodeError())
        }
        let callback = JSValueCallback(callback: callbackFunction)
        return .success({ [weak self] (arg0: T, arg1: U) in
            guard let self = self else { return } // TODO: throw
            guard let result0 = try? self.encode(arg0).get() as Any else { return }
            guard let result1 = try? self.encode(arg1).get() as Any else { return }
            try? callback.call(args: [result0, result1])
        })
    }

    /**
     An implementation of the `JSEvaluating` protocol.
     */
    public func evaluate<R: Decodable>(
        _ identifierPath: String,
        with args: [Encodable],
        callback: @escaping (Error?, R?) -> Void
    ) {
        bridge?.evaluate(identifierPath, with: args, callback: callback)
    }

    private let namespace: String
    private weak var context: JSContext?
    private var bridge: JSEvaluating?
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
        let functionType = context.globalObject.objectForKeyedSubscript("Function")
        return isInstance(of: functionType)
    }
}
