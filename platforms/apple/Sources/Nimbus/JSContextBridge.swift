//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import Foundation
import JavaScriptCore

public class JSContextBridge {

    public func addPlugin<T: Plugin>(_ plugin: T) {
        plugins.append(plugin)
    }

    public func attach(to context: JSContext) {
        guard self.context == nil else {
            return
        }

        self.context = context
        for plugin in plugins {
            let connection = JSContextConnection(from: context, as: plugin.namespace)
            plugin.bind(to: connection)
        }
    }

    var plugins: [Plugin] = []
    var context: JSContext?
}
