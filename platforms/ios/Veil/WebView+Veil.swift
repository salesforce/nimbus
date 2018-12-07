// Copyright (c) 2018, salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause


import WebKit

extension WKWebView {

    /**
     Create a connection from this web view to the specified object.
     */
    public func addConnection<C>(to target: C, as namespace: String) -> Connection<C> {
        return Connection(from: self, to: target, as: namespace)
    }
}
