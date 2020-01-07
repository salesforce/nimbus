//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 `Callable` is a type-erasing function-like wrapper to provide
 a homogenous interface to functions.
 */
public protocol Callable {
    /**
     Call the wrapped function with the specified arguments.
     - Throws when the argument types or arity to not match
     */
    func call(args: [Any], forPromisifiedClosure: Bool) throws -> Any
}

/// Represents an error when the type or number of arguments is incorrect
enum ParameterError: Error, Equatable {
    case conversion
    case argumentCount(expected: Int, actual: Int)
    case promiseWithCallback
}
