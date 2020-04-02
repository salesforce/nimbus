//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextConnection: Connection {

    init(from context: JSContext, as namespace: String) {
        self.context = context
        self.namespace = namespace
    }

    public func bind(_ callable: Callable, as name: String) {
        // TODO:
    }

    public func call(_ method: String, args: [Any], promise: String) {
        // TODO:
    }

    private let namespace: String
    private weak var context: JSContext?
    private var bindings: [String: Callable] = [:]
}
