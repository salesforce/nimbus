//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextConnection: Connection {

    init(from context: JSContext, as namespace: String) {
        self.context = context
        self.namespace = namespace
    }

    public func bind(_ callable: Callable, as name: String) {
        guard let context = self.context else {
            return
        }
        // get the __nimbus object
//        var nimbusGlobal = context.objectForKeyedSubscript("__nimbus")?.toDictionary()
//        // create it if it's nil
//        if nimbusGlobal == nil {
//            nimbusGlobal = [:] as [AnyHashable: Any]
//        }
//
//        // get the plugins array
//        var plugins = nimbusGlobal["plugins"] as [Any]?
//        // create it if it's nil
//        if plugins == nil {
//            plugins = []
//        }
//
//        // get the name plugin on __nimbus
//        var plugin = plugins?.objectForKeyedSubscript(namespace)
//        // create it if it's nil
//        if plugin == nil {
//            plugin = JSValue(newObjectIn: context)
//        }

        // create an objc block
        let binding: @convention(block) (Any?) -> Any? = { args in
            // call the callable in the block, coercing params
            do {
                // return the result
                let arguments: [Any]
                if let args = args {
                    arguments = [args]
                } else {
                    arguments = []
                }
                return try callable.call(args: arguments)
            } catch {
                // Do something with the error
            }
            return nil
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
}
