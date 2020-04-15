//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextConnection: Connection {

    init(from context: JSContext, as namespace: String) {
        self.context = context
        self.namespace = namespace
        self.promiseGlobal = context.objectForKeyedSubscript("Promise")
    }

    public func bind(_ callable: Callable, as name: String) {
        guard let context = self.context else {
            return
        }
        bindings[name] = callable
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

        // bind the block as name
        context.globalObject.setObject(binding, forKeyedSubscript: name)

        let assignmentJS = """
        var plugin = __nimbus.plugins["\(namespace)"];
        if (plugin === undefined) {
            plugin = {};
            __nimbus.plugins["\(namespace)"] = plugin;
        }
        __nimbus.plugins.\(namespace)["\(name)"] = \(name);
        delete \(name);
        """

        context.evaluateScript(assignmentJS)
    }

    public func call(_ method: String, args: [Any], promise: String) {
        // TODO:
    }

    private let namespace: String
    private weak var context: JSContext?
    private var bindings: [String: Callable] = [:]
    private let promiseGlobal: JSValue?
}

extension Encodable {
    func toJSValue(context: JSContext) throws -> JSValue {
        return try JSValueEncoder().encode(self, context: context)
    }
}

extension JSValue {
    func isFunction() -> Bool {
        let prototype = context.evaluateScript("Object.prototype.toString")
        let result = prototype?.invokeMethod("call", withArguments: [self])
        if result?.isString == true && result?.toString() == "[object Function]" {
            return true
        }
        return false
    }
}
