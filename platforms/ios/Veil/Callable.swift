/**
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
 `Callable` is a type-erasing function-like wrapper to provide
 a homogenous interface to functions.
 */
protocol Callable {

    /**
     Call the wrapped function with the specified arguments.
     - Throws when the argument types or arity to not match
     */
    func call(args: [Any]) throws -> Any;
}

/// Represents an error when the type or number of arguments is incorrect
struct ParameterError : Error {}

/**
 A `Callable` wrapper for nullary functions
 */
struct Callable0<R> : Callable {
    typealias FunctionType = () -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        return f()
    }
}

/**
 A `Callable` wrapper for unary functions
 */
struct Callable1<R, A0> : Callable {
    typealias FunctionType = (A0) -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        if let a0 = args[0] as? A0 {
            return f(a0)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for binary functions
 */
struct Callable2<R, A0, A1> : Callable {
    typealias FunctionType = (A0, A1) -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        if  let a0 = args[0] as? A0,
            let a1 = args[1] as? A1 {
            return f(a0, a1)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for ternary functions
 */
struct Callable3<R, A0, A1, A2> : Callable {
    typealias FunctionType = (A0, A1, A2) -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        if  let a0 = args[0] as? A0,
            let a1 = args[1] as? A1,
            let a2 = args[2] as? A2 {
            return f(a0, a1, a2)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for 4-ary functions
 */
struct Callable4<R, A0, A1, A2, A3> : Callable {
    typealias FunctionType = (A0, A1, A2, A3) -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        if  let a0 = args[0] as? A0,
            let a1 = args[1] as? A1,
            let a2 = args[2] as? A2,
            let a3 = args[3] as? A3 {
            return f(a0, a1, a2, a3)
        }
        throw ParameterError()
    }
}

/**
 A `Callable` wrapper for 5-ary functions
 */
struct Callable5<R, A0, A1, A2, A3, A4> : Callable {
    typealias FunctionType = (A0, A1, A2, A3, A4) -> R
    let f: FunctionType

    init(_ f: @escaping FunctionType) {
        self.f = f
    }

    func call(args: [Any]) throws -> Any {
        if  let a0 = args[0] as? A0,
            let a1 = args[1] as? A1,
            let a2 = args[2] as? A2,
            let a3 = args[3] as? A3,
            let a4 = args[4] as? A4 {
            return f(a0, a1, a2, a3, a4)
        }
        throw ParameterError()
    }
}

/**
 Create a `Callable` from a nullary function.
 */
func make_callable<R>(_ f: @escaping () -> R) -> Callable {
    return Callable0(f)
}

/**
 Create a `Callable` from the unary function.
 */
func make_callable<R, A0>(_ f: @escaping ((A0)) -> R) -> Callable {
    return Callable1(f)
}

/**
 Create a `Callable` from the binary function.
 */
func make_callable<R, A0, A1>(_ f: @escaping (A0, A1) -> R) -> Callable {
    return Callable2(f)
}

/**
 Create a `Callable` from the ternary function.
 */
func make_callable<R, A0, A1, A2>(_ f: @escaping (A0, A1, A2) -> R) -> Callable {
    return Callable3(f)
}

/**
 Create a `Callable` from the quaternary function.
 */
func make_callable<R, A0, A1, A2, A3>(_ f: @escaping (A0, A1, A2, A3) -> R) -> Callable {
    return Callable4(f)
}

/**
 Create a `Callable` from the quinary function.
 */
func make_callable<R, A0, A1, A2, A3, A4>(_ f: @escaping (A0, A1, A2, A3, A4) -> R) -> Callable {
    return Callable5(f)
}
