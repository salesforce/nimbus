//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

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
enum ParameterError: Error, Equatable {
    case conversion
    case argumentCount(expected: Int, actual: Int)
}

/**
 A `Callable` wrapper for nullary functions
 */
struct Callable0<R>: Callable {
    typealias FunctionType = () throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 0 {
            throw ParameterError.argumentCount(expected: 0, actual: args.count)
        }
        return try function()
    }
}
/**
 A `Callable` wrapper for unary functions
 */
struct Callable1<R, A0>: Callable {
    typealias FunctionType = (A0) throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 1 {
            throw ParameterError.argumentCount(expected: 1, actual: args.count)
        }
        let decodedArg0 = decodedArg(value: args[0], type: A0.self)
        if let arg0 = decodedArg0 ?? args[0] as? A0 {
            return try function(arg0)
        }
        throw ParameterError.conversion
    }
}
/**
 A `Callable` wrapper for binary functions
 */
struct Callable2<R, A0, A1>: Callable {
    typealias FunctionType = (A0, A1) throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 2 {
            throw ParameterError.argumentCount(expected: 2, actual: args.count)
        }
        let decodedArg0 = decodedArg(value: args[0], type: A0.self)
        let decodedArg1 = decodedArg(value: args[1], type: A1.self)
        if let arg0 = decodedArg0 ?? args[0] as? A0,
            let arg1 = decodedArg1 ?? args[1] as? A1 {
            return try function(arg0, arg1)
        }
        throw ParameterError.conversion
    }
}
/**
 A `Callable` wrapper for ternary functions
 */
struct Callable3<R, A0, A1, A2>: Callable {
    typealias FunctionType = (A0, A1, A2) throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 3 {
            throw ParameterError.argumentCount(expected: 3, actual: args.count)
        }
        let decodedArg0 = decodedArg(value: args[0], type: A0.self)
        let decodedArg1 = decodedArg(value: args[1], type: A1.self)
        let decodedArg2 = decodedArg(value: args[2], type: A2.self)
        if let arg0 = decodedArg0 ?? args[0] as? A0,
            let arg1 = decodedArg1 ?? args[1] as? A1,
            let arg2 = decodedArg2 ?? args[2] as? A2 {
            return try function(arg0, arg1, arg2)
        }
        throw ParameterError.conversion
    }
}
/**
 A `Callable` wrapper for quaternary functions
 */
struct Callable4<R, A0, A1, A2, A3>: Callable {
    typealias FunctionType = (A0, A1, A2, A3) throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 4 {
            throw ParameterError.argumentCount(expected: 4, actual: args.count)
        }
        let decodedArg0 = decodedArg(value: args[0], type: A0.self)
        let decodedArg1 = decodedArg(value: args[1], type: A1.self)
        let decodedArg2 = decodedArg(value: args[2], type: A2.self)
        let decodedArg3 = decodedArg(value: args[3], type: A3.self)
        if let arg0 = decodedArg0 ?? args[0] as? A0,
            let arg1 = decodedArg1 ?? args[1] as? A1,
            let arg2 = decodedArg2 ?? args[2] as? A2,
            let arg3 = decodedArg3 ?? args[3] as? A3 {
            return try function(arg0, arg1, arg2, arg3)
        }
        throw ParameterError.conversion
    }
}
/**
 A `Callable` wrapper for quinary functions
 */
struct Callable5<R, A0, A1, A2, A3, A4>: Callable {
    typealias FunctionType = (A0, A1, A2, A3, A4) throws -> R
    let function: FunctionType

    init(_ function: @escaping FunctionType) {
        self.function = function
    }

    func call(args: [Any]) throws -> Any {
        if args.count != 5 {
            throw ParameterError.argumentCount(expected: 5, actual: args.count)
        }
        let decodedArg0 = decodedArg(value: args[0], type: A0.self)
        let decodedArg1 = decodedArg(value: args[1], type: A1.self)
        let decodedArg2 = decodedArg(value: args[2], type: A2.self)
        let decodedArg3 = decodedArg(value: args[3], type: A3.self)
        let decodedArg4 = decodedArg(value: args[4], type: A4.self)
        if let arg0 = decodedArg0 ?? args[0] as? A0,
            let arg1 = decodedArg1 ?? args[1] as? A1,
            let arg2 = decodedArg2 ?? args[2] as? A2,
            let arg3 = decodedArg3 ?? args[3] as? A3,
            let arg4 = decodedArg4 ?? args[4] as? A4 {
            return try function(arg0, arg1, arg2, arg3, arg4)
        }
        throw ParameterError.conversion
    }
}

/**
 Create a `Callable` from the nullary function.
 */
func make_callable<R>(_ function: @escaping (()) throws -> R) -> Callable {
    return Callable0(function)
}

/**
 Create a `Callable` from the unary function.
 */
func make_callable<R, A0>(_ function: @escaping ((A0)) throws -> R) -> Callable {
    return Callable1(function)
}

/**
 Create a `Callable` from the binary function.
 */
func make_callable<R, A0, A1>(_ function: @escaping ((A0, A1)) throws -> R) -> Callable {
    return Callable2(function)
}

/**
 Create a `Callable` from the ternary function.
 */
func make_callable<R, A0, A1, A2>(_ function: @escaping ((A0, A1, A2)) throws -> R) -> Callable {
    return Callable3(function)
}

/**
 Create a `Callable` from the quaternary function.
 */
func make_callable<R, A0, A1, A2, A3>(_ function: @escaping ((A0, A1, A2, A3)) throws -> R) -> Callable {
    return Callable4(function)
}

/**
 Create a `Callable` from the quinary function.
 */
func make_callable<R, A0, A1, A2, A3, A4>(_ function: @escaping ((A0, A1, A2, A3, A4)) throws -> R) -> Callable {
    return Callable5(function)
}

private func decodedArg<A>(value: Any?, type: A.Type) -> A? {
    if let jsArg = value as? JSValue {
        return decodeJSValue(jsArg, destinationType: type)
    }
    if let argString = value as? String,
        let data = argString.data(using: .utf8) {
        return decodeJSON(data, destinationType: type)
    }
    return nil
}
