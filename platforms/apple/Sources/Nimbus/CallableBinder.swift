//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

/**
 `CallableBinder` is an extension to `Binder` that provides default
 implementations of all `bind` overloads based around the use of the
 `Callable` implementations to wrap function arguments.
 */
protocol CallableBinder: Binder {
    func bind(_ callable: Callable, as name: String)
}

extension CallableBinder {
    public func bind(
        _ function: @escaping () throws -> Void,
        as name: String
    ) {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable>(
        _ function: @escaping () throws -> R,
        as name: String
    ) {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<A0>(
        _ function: @escaping (A0) throws -> Void,
        as name: String
    ) where A0: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable, A0>(
        _ function: @escaping (A0) throws -> R,
        as name: String
    ) where A0: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<CB0: Encodable>(
        _ function: @escaping (@escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) {
        let wrappedFunction = { (callable: Callable) -> Void in
            try function { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (@escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) {
        let wrappedFunction = { (callable: Callable) -> Void in
            try function { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1>(
        _ function: @escaping (A0, A1) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable, A0, A1>(
        _ function: @escaping (A0, A1) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<A0, CB0: Encodable>(
        _ function: @escaping (A0, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable {
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try function(arg0) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable {
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try function(arg0) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2>(
        _ function: @escaping (A0, A1, A2) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable, A0, A1, A2>(
        _ function: @escaping (A0, A1, A2) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<A0, A1, CB0: Encodable>(
        _ function: @escaping (A0, A1, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try function(arg0, arg1) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, A1, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try function(arg0, arg1) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, A3>(
        _ function: @escaping (A0, A1, A2, A3) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable, A0, A1, A2, A3>(
        _ function: @escaping (A0, A1, A2, A3) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, CB0: Encodable>(
        _ function: @escaping (A0, A1, A2, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try function(arg0, arg1, arg2) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try function(arg0, arg1, arg2) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, A3, A4>(
        _ function: @escaping (A0, A1, A2, A3, A4) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<R: Encodable, A0, A1, A2, A3, A4>(
        _ function: @escaping (A0, A1, A2, A3, A4) throws -> R,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let callable = make_callable(function)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, A3, CB0: Encodable>(
        _ function: @escaping (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try function(arg0, arg1, arg2, arg3) { cb0 in
                _ = try! callable.call(args: [cb0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    public func bind<A0, A1, A2, A3, CB0: Encodable, CB1: Encodable>(
        _ function: @escaping (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> Void,
        as name: String
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try function(arg0, arg1, arg2, arg3) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }
}
