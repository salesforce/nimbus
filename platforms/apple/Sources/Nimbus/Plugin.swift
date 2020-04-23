//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 A plugin integrates native capabilities into a JavaScript runtime environment.
 */
public protocol Plugin: class {
    var namespace: String { get }

    /**
     Bind this plugin to the specified connection.

     Plugins can implement the bind method to add connections and expose methods
     to a web view or `JSContext`.
     */
    func bind<C>(to connection: C) where C: Connection
}

/**
 A default implementation of the `Plugin` protocol.
 */
public extension Plugin {
    /**
     By default, types conforming to `Plugin` provide the string equivalent of the class name as the namespace. Override this in a `Plugin` conforming type to provide a different value.
     */
    var namespace: String {
        let currentType = type(of: self)
        return String(describing: currentType)
    }
}
