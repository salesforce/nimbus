//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

public protocol NativeBinder {
    associatedtype Target
    var target: Target { get }

    func bind(_ callable: Callable, as name: String)
}

public protocol WebBinder: class {
    func invoke<R>(_ functionName: String, with args: Encodable..., promiseCompletion: @escaping (Error?, R?) -> Void)
}

public typealias Binder = NativeBinder & WebBinder
