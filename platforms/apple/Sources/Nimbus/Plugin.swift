//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 A plugin integrates native capabilities into a JavaScript runtime environment.
 */
public protocol Plugin: class {
    var namespace: String { get }

    /**
     Bind this plugin to the specified web view and Nimbus bridge.

     Plugins can implement the bind method to add connections and expose methods
     to the web view, make additional configuration changes to the web view, or
     call additional methods on the nimbus bridge prior to the web app being loaded.
     */
    func bind<C>(to connection: C) where C: Connection
}

public extension Plugin {
    var namespace: String {
        return String(describing: self)
    }
}
