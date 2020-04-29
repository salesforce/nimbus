//
//  JavaScriptCoreGlobals.swift
//  NimbusTests
//
//  Created by Paul Tiarks on 4/29/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import JavaScriptCore
import Foundation

class JavaScriptCoreGlobalsProvider {
    let context: JSContext
//    let timeoutQueue: DispatchQueue
    var callbacks: [String: JSValue] = [:]

    init(context: JSContext) {
        self.context = context
        setupGlobals()
    }

    func setupGlobals() {
        let timeout: @convention(block) () -> Any? = {
            let args: [Any] = JSContext.currentArguments() ?? []
            guard let function = args[0] as? JSValue, let timeout = args[1] as? JSValue else {
                return nil
            }
            var additionalArguments: [Any] = []
            var index = 0
            args.forEach { value in
                if index > 1 {
                    additionalArguments.append(value)
                }
                index = index.advanced(by: 1)
            }

            let milliseconds = timeout.toInt32()
            let dispatchTime = DispatchTimeInterval.milliseconds(Int(milliseconds))
            let newUUID = UUID().uuidString
            self.callbacks[newUUID] = function
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTime) {
                if let functionToCall = self.callbacks[newUUID], function == functionToCall {
                    function.call(withArguments: additionalArguments)
                    self.callbacks[newUUID] = nil
                }
            }

            return newUUID
        }
        context.setObject(timeout, forKeyedSubscript: "setTimeout" as NSString)

        let clearTimeout: @convention(block) () -> Any? = {
            let args: [Any] = JSContext.currentArguments() ?? []
            guard let timeoutId = args[0] as? JSValue, timeoutId.isString, let uuid = timeoutId.toString() else {
                return nil
            }
            self.callbacks[uuid] = nil
            return nil
        }
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)

        //TODO: Setup setInterval, and clearInterval
    }
}
