// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore

class JSValueCallback: Callable {

    init(callback: JSValue) {
        self.callback = callback
    }

    func call(args: [Any]) throws -> Any {
        guard let context = callback?.context else {
            return 0
        }
        // encode the args to JSValue
        let jsArgs = try args.map { arg -> JSValue in
            if type(of: arg) as? Encodable.Type != nil {
                let encodableArg = arg as! Encodable // swiftlint:disable:this force_cast
                return try encodableArg.toJSValue(context: context)
            } else {
                throw ParameterError.conversion
            }
        }

        // call the function
        return callback?.call(withArguments: jsArgs) ?? 0
    }

    var callback: JSValue?
}
