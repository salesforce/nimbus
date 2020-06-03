//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

/**
 An error describing a failure in a `JSValueCallback`
 */
enum JSValueCallbackError: Error {
    /**
     Invoking the `JSValue` returned nil, indicating the javascript object was not a valid function
     */
    case invalidCallback
}

/**
 `JSValueCallback` is a native proxy to a javascript function that
 is used for passing callbacks across the bridge.
 */
class JSValueCallback {
    init(callback: JSValue) {
        self.callback = callback
    }

    func call(args: [Any]) throws {
        guard let _ = callback?.call(withArguments: args) else { // swiftlint:disable:this unused_optional_binding
            throw JSValueCallbackError.invalidCallback
        }
    }

    var callback: JSValue?
}
