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

        // create an objc block
        let binding: @convention(block) () -> Any? = {
            let args = JSContext.currentArguments()
            do {
                var resultArguments: [Any] = []
                let rawResult = try callable.call(args: args ?? [])
                if let intResult = rawResult as? Int {
                    let jsResult = try? JSValueEncoder().encode(intResult, context: context)
                    if let jsResult = jsResult {
                        resultArguments.append(jsResult)
                    }
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
