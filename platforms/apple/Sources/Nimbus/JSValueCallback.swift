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

 */
enum JSValueCallbackError: Error {
    case invalidContext
    case invalidCallback
}

/**
 `JSValueCallback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class JSValueCallback: Callable {
    init(callback: JSValue) {
        self.callback = callback
    }

    func call(args: [Any]) throws -> Any {
        guard let context = callback?.context else {
            throw JSValueCallbackError.invalidContext
        }
        let jsArgs = try args.map { arg -> JSValue in
            if type(of: arg) as? Encodable.Type != nil {
                let encodableArg = arg as! Encodable // swiftlint:disable:this force_cast
                return try encodableArg.toJSValue(context: context)
            } else {
                throw ParameterError.conversion
            }
        }

        let result = callback?.call(withArguments: jsArgs)
        if let result = result {
            return result
        } else {
            throw JSValueCallbackError.invalidCallback
        }
    }

    var callback: JSValue?
}
