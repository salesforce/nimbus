//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSContextConnection<C>: Connection {
    public typealias Target = C


    init(from context: JSContext, to target: C, as namespace: String) {
        self.context = context
        self.target = target
        self.namespace = namespace
    }

    public func bind(_ callable: Callable, as name: String) {
        // TODO:
    }

    public func call(_ method: String, args: [Any], promise: String) {
        // TODO:
    }

    public let target: C
    private let namespace: String
    private weak var context: JSContext?
    private var bindings: [String: Callable] = [:]
}
