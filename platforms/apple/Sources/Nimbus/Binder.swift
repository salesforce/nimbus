//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable line_length

public protocol Binder {
    associatedtype Target
    var target: Target { get }

    func bind(_ callable: Callable, as name: String)
}

extension Binder {
    /**
     Bind the specified function to this connection.
     */
    public func bind(_ function: @escaping (Target) -> () throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable>(_ function: @escaping (Target) -> () throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (Target) -> (A0) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0>(_ function: @escaping (Target) -> (A0) throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CB0: Encodable>(_ function: @escaping (Target) -> (@escaping (CB0) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CB0, CB1: Encodable>(_ function: @escaping (Target) -> (@escaping (CB0, CB1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CB0) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0, CB1: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CB0, CB1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0, CB1) -> Void) throws -> Void,
                                                  as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0) -> Void) throws -> Void,
                                                 as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> Void,
                                                      as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> R, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> Void,
                                                     as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> Void,
                                                          as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }
}
