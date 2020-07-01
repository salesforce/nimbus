//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable identifier_name file_length

typealias Callable = ([Any?]) throws -> Any?

/// Represents an error when the type or number of arguments is incorrect
enum ParameterError: Error, Equatable {
    case conversion
    case argumentCount(expected: Int, actual: Int)
}

struct DecodeError: Error {}
struct EncodeError: Error {}

/**
 `CallableBinder` is an extension to `Binder` that provides default
 implementations of all `bind` overloads based around the use of the
 `Callable` implementations to wrap function arguments.
 */
protocol CallableBinder: class, Binder {
    // Bind a generic `Callable` into this specific bridge
    func bindCallable(_ name: String, to callable: @escaping Callable)

    // Decode a value, used for converting incoming function arguments from
    // bridge types to native types (e.g. json string -> Foo: Decodable)
    func decode<T: Decodable>(_ value: Any?, as type: T.Type) -> Result<T, Error>

    func encode<T: Encodable>(_ value: T) -> Result<Any?, Error>

    func callback<T: Encodable>(from value: Any?, taking argType: T.Type) -> Result<(T) -> Void, Error>

    func callback<T: Encodable, U: Encodable>(from value: Any?, taking argType: (T.Type, U.Type)) -> Result<(T, U) -> Void, Error>
}

extension CallableBinder {
    @usableFromInline
    @inline(__always)
    internal func assertArgsCount(expected: Int, actual: Int) throws {
        if expected != actual {
            throw ParameterError.argumentCount(expected: expected, actual: actual)
        }
    }

    public func bind(
        _ name: String,
        to function: @escaping () throws -> Void
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            try self?.assertArgsCount(expected: 0, actual: args.count)
            return try function()
        }
    }

    public func bind<R: Encodable>(
        _ name: String,
        to function: @escaping () throws -> R
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            try self?.assertArgsCount(expected: 0, actual: args.count)
            return try self?.encode(try function()).get()
        }
    }

    public func bind<A0>(
        _ name: String,
        to function: @escaping (A0) throws -> Void
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            return try function(a0)
        }
    }

    public func bind<R: Encodable, A0>(
        _ name: String,
        to function: @escaping (A0) throws -> R
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            return try self.encode(try function(a0)).get()
        }
    }

    public func bind<CB0: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0) -> Void) throws -> Void
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let callback = try self.callback(from: args[0], taking: CB0.self).get()
            return try function(callback)
        }
    }

    public func bind<R: Encodable, CB0: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0) -> Void) throws -> R
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let callback = try self.callback(from: args[0], taking: CB0.self).get()
            return try self.encode(try function(callback)).get()
        }
    }

    public func bind<CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0, CB1) -> Void) throws -> Void
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let callback = try self.callback(from: args[0], taking: (CB0.self, CB1.self)).get()
            return try function(callback)
        }
    }

    public func bind<CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> Void
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let cb0 = try self.callback(from: args[0], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[1], taking: CB1.self).get()
            return try function(cb0, cb1)
        }
    }

    public func bind<R: Encodable, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0, CB1) -> Void) throws -> R
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 1, actual: args.count)
            let callback = try self.callback(from: args[0], taking: (CB0.self, CB1.self)).get()
            return try self.encode(function(callback)).get()
        }
    }

    public func bind<R: Encodable, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (@escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> R
    ) {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let cb0 = try self.callback(from: args[0], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[1], taking: CB1.self).get()
            return try self.encode(function(cb0, cb1)).get()
        }
    }

    public func bind<A0, A1>(
        _ name: String,
        to function: @escaping (A0, A1) throws -> Void
    ) where A0: Decodable, A1: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            return try function(a0, a1)
        }
    }

    public func bind<R: Encodable, A0, A1>(
        _ name: String,
        to function: @escaping (A0, A1) throws -> R
    ) where A0: Decodable, A1: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            return try self.encode(try function(a0, a1)).get()
        }
    }

    public func bind<A0, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0) -> Void) throws -> Void
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let callback = try self.callback(from: args[1], taking: CB0.self).get()
            return try function(a0, callback)
        }
    }

    public func bind<R: Encodable, A0, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0) -> Void) throws -> R
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let callback = try self.callback(from: args[1], taking: CB0.self).get()
            return try self.encode(function(a0, callback)).get()
        }
    }

    public func bind<A0, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0, CB1) -> Void) throws -> Void
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let callback = try self.callback(from: args[1], taking: (CB0.self, CB1.self)).get()
            return try function(a0, callback)
        }
    }

    public func bind<R: Encodable, A0, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0, CB1) -> Void) throws -> R
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 2, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let callback = try self.callback(from: args[1], taking: (CB0.self, CB1.self)).get()
            return try self.encode(function(a0, callback)).get()
        }
    }

    public func bind<A0, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> Void
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let cb0 = try self.callback(from: args[1], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[2], taking: CB1.self).get()
            return try function(a0, cb0, cb1)
        }
    }

    public func bind<R: Encodable, A0, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> R
    ) where A0: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let cb0 = try self.callback(from: args[1], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[2], taking: CB1.self).get()
            return try self.encode(function(a0, cb0, cb1)).get()
        }
    }

    public func bind<A0, A1, A2>(
        _ name: String,
        to function: @escaping (A0, A1, A2) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            return try function(a0, a1, a2)
        }
    }

    public func bind<R: Encodable, A0, A1, A2>(
        _ name: String,
        to function: @escaping (A0, A1, A2) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            return try self.encode(try function(a0, a1, a2)).get()
        }
    }

    public func bind<A0, A1, CB0>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, CB0: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let callback = try self.callback(from: args[2], taking: CB0.self).get()
            return try function(a0, a1, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, CB0>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, CB0: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let callback = try self.callback(from: args[2], taking: CB0.self).get()
            return try self.encode(function(a0, a1, callback)).get()
        }
    }

    public func bind<A0, A1, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0, CB1) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let callback = try self.callback(from: args[2], taking: (CB0.self, CB1.self)).get()
            return try function(a0, a1, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0, CB1) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 3, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let callback = try self.callback(from: args[2], taking: (CB0.self, CB1.self)).get()
            return try self.encode(function(a0, a1, callback)).get()
        }
    }

    public func bind<A0, A1, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let cb0 = try self.callback(from: args[2], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[3], taking: CB1.self).get()
            return try function(a0, a1, cb0, cb1)
        }
    }

    public func bind<R: Encodable, A0, A1, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let cb0 = try self.callback(from: args[2], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[3], taking: CB1.self).get()
            return try self.encode(function(a0, a1, cb0, cb1)).get()
        }
    }

    public func bind<A0, A1, A2, A3>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            return try function(a0, a1, a2, a3)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, A3>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            return try self.encode(try function(a0, a1, a2, a3)).get()
        }
    }

    public func bind<A0, A1, A2, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let callback = try self.callback(from: args[3], taking: CB0.self).get()
            return try function(a0, a1, a2, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let callback = try self.callback(from: args[3], taking: CB0.self).get()
            return try self.encode(function(a0, a1, a2, callback)).get()
        }
    }

    public func bind<A0, A1, A2, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let callback = try self.callback(from: args[3], taking: (CB0.self, CB1.self)).get()
            return try function(a0, a1, a2, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 4, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let callback = try self.callback(from: args[3], taking: (CB0.self, CB1.self)).get()
            return try self.encode(function(a0, a1, a2, callback)).get()
        }
    }

    public func bind<A0, A1, A2, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let cb0 = try self.callback(from: args[3], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[4], taking: CB1.self).get()
            return try function(a0, a1, a2, cb0, cb1)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, CB0, CB1>(
        _ name: String,
        to function: @escaping (A0, A1, A2, @escaping (CB0) -> Void, @escaping (CB1) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable, CB0: Encodable, CB1: Encodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let cb0 = try self.callback(from: args[3], taking: CB0.self).get()
            let cb1 = try self.callback(from: args[4], taking: CB1.self).get()
            return try self.encode(function(a0, a1, a2, cb0, cb1)).get()
        }
    }

    public func bind<A0, A1, A2, A3, A4>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, A4) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let a4 = try self.decode(args[4], as: A4.self).get()
            return try function(a0, a1, a2, a3, a4)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, A3, A4>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, A4) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let a4 = try self.decode(args[4], as: A4.self).get()
            return try self.encode(try function(a0, a1, a2, a3, a4)).get()
        }
    }

    public func bind<A0, A1, A2, A3, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let callback = try self.callback(from: args[4], taking: CB0.self).get()
            return try function(a0, a1, a2, a3, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, A3, CB0: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let callback = try self.callback(from: args[4], taking: CB0.self).get()
            return try self.encode(function(a0, a1, a2, a3, callback)).get()
        }
    }

    public func bind<A0, A1, A2, A3, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> Void
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let callback = try self.callback(from: args[4], taking: (CB0.self, CB1.self)).get()
            return try function(a0, a1, a2, a3, callback)
        }
    }

    public func bind<R: Encodable, A0, A1, A2, A3, CB0: Encodable, CB1: Encodable>(
        _ name: String,
        to function: @escaping (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> R
    ) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        bindCallable(name) { [weak self] (args: [Any?]) in
            guard let self = self else { throw DecodeError() }
            try self.assertArgsCount(expected: 5, actual: args.count)
            let a0 = try self.decode(args[0], as: A0.self).get()
            let a1 = try self.decode(args[1], as: A1.self).get()
            let a2 = try self.decode(args[2], as: A2.self).get()
            let a3 = try self.decode(args[3], as: A3.self).get()
            let callback = try self.callback(from: args[4], taking: (CB0.self, CB1.self)).get()
            return try self.encode(function(a0, a1, a2, a3, callback)).get()
        }
    }
}
