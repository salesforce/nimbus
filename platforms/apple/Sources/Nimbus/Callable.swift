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
    func call(args: [Any]) throws -> Any
}

/// Represents an error when the type or number of arguments is incorrect
struct ParameterError: Error {}

/**
 A `Callable` wrapper for nullary functions
 */
struct Callable0<R>: Callable {
    typealias FunctionType = () -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args _: [Any]) throws -> Any {
        return function()
    }
}

/**
 A `Callable` wrapper for unary functions
 */
struct Callable1<R, A0>: Callable {
    typealias FunctionType = (A0) -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if let arg0 = args[0] as? A0 {
            return function(arg0)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for binary functions
 */
struct Callable2<R, A0, A1>: Callable {
    typealias FunctionType = (A0, A1) -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if let arg0 = args[0] as? A0,
            let arg1 = args[1] as? A1 {
            return function(arg0, arg1)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for ternary functions
 */
struct Callable3<R, A0, A1, A2>: Callable {
    typealias FunctionType = (A0, A1, A2) -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if let arg0 = args[0] as? A0,
            let arg1 = args[1] as? A1,
            let arg2 = args[2] as? A2 {
            return function(arg0, arg1, arg2)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for 4-ary functions
 */
struct Callable4<R, A0, A1, A2, A3>: Callable {
    typealias FunctionType = (A0, A1, A2, A3) -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if let arg0 = args[0] as? A0,
            let arg1 = args[1] as? A1,
            let arg2 = args[2] as? A2,
            let arg3 = args[3] as? A3 {
            return function(arg0, arg1, arg2, arg3)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for 5-ary functions
 */
struct Callable5<R, A0, A1, A2, A3, A4>: Callable {
    typealias FunctionType = (A0, A1, A2, A3, A4) -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if let arg0 = args[0] as? A0,
            let arg1 = args[1] as? A1,
            let arg2 = args[2] as? A2,
            let arg3 = args[3] as? A3,
            let arg4 = args[4] as? A4 {
            return function(arg0, arg1, arg2, arg3, arg4)
        }
        throw ParameterError()
    }
}

/**
 Create a `Callable` from a nullary function.
 */
func make_callable<R>(_ function: @escaping (()) -> R) -> Callable {
    return Callable0(function)
}

/**
 Create a `Callable` from the unary function.
 */
// swiftformat:disable:next redundantParens
func make_callable<R, A0>(_ function: @escaping ((A0)) -> R) -> Callable {
    return Callable1(function)
}

/**
 Create a `Callable` from the binary function.
 */
func make_callable<R, A0, A1>(_ function: @escaping ((A0, A1)) -> R) -> Callable {
    return Callable2(function)
}

/**
 Create a `Callable` from the ternary function.
 */
func make_callable<R, A0, A1, A2>(_ function: @escaping ((A0, A1, A2)) -> R) -> Callable {
    return Callable3(function)
}

/**
 Create a `Callable` from the quaternary function.
 */
func make_callable<R, A0, A1, A2, A3>(_ function: @escaping ((A0, A1, A2, A3)) -> R) -> Callable {
    return Callable4(function)
}

/**
 Create a `Callable` from the quinary function.
 */
func make_callable<R, A0, A1, A2, A3, A4>(_ function: @escaping ((A0, A1, A2, A3, A4)) -> R) -> Callable {
    return Callable5(function)
}
