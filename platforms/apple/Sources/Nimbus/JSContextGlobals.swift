//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextGlobals {
    private static var intervals: [String: Timer] = [:]

    public static func setupGlobals(context: JSContext) {
        let setTimeout: @convention(block) () -> Any? = {
            self.setInterval(repeats: false)
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)

        let setInterval: @convention(block) () -> Any? = {
            self.setInterval(repeats: true)
        }
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)

        let clearInterval: @convention(block) (JavaScriptCore.JSValue) -> Void = { (value: JavaScriptCore.JSValue) in
            self.clearInterval(hashValue: value.toString())
        }
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)
        context.setObject(clearInterval, forKeyedSubscript: "clearTimeout" as NSString)
    }

    private static func setInterval(repeats: Bool) -> String {
        let args: [Any] = JSContext.currentArguments() ?? []
        guard let function = args[0] as? JSValue,
            let timeout = args[1] as? JSValue else {
            // Valid timeout ID is positive. If the guard fails return 0.
            // https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/setTimeout
            return "0"
        }
        var additionalArguments: [Any] = []
        var index = 0
        args.forEach { value in
            if index > 1 {
                additionalArguments.append(value)
            }
            index = index.advanced(by: 1)
        }
        let milliseconds = timeout.toInt32() / 1000
        let hashValue = UUID().uuidString
        intervals[hashValue] = Timer.scheduledTimer(withTimeInterval: TimeInterval(milliseconds), repeats: repeats) { _ in
            function.call(withArguments: additionalArguments)
        }
        return hashValue
    }

    private static func clearInterval(hashValue: String) {
        intervals[hashValue]?.invalidate()
        intervals[hashValue] = nil
    }
}
