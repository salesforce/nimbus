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
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchTime) {
                function.call(withArguments: additionalArguments)
            }

            return nil
        }
        context.setObject(timeout, forKeyedSubscript: "setTimeout" as NSString)

        //TODO: Setup setInterval, clearTimeout, and clearInterval
    }
}
