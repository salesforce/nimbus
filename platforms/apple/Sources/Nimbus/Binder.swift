//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable line_length file_length

import Foundation

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
    public func bind(_ function: @escaping (Target) -> () throws -> NSArray, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind(_ function: @escaping (Target) -> () throws -> NSDictionary, as name: String) {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (Target) -> (A0) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0>(_ function: @escaping (Target) -> (A0) throws -> R, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (Target) -> (A0) throws -> NSArray, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (Target) -> (A0) throws -> NSDictionary, as name: String) where A0: Decodable {
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
    public func bind(_ function: @escaping (Target) -> (@escaping (NSArray) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cba0 in
                _ = try! callable.call(args: [cba0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind(_ function: @escaping (Target) -> (@escaping (NSDictionary) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cbd0 in
                _ = try! callable.call(args: [cbd0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CB0: Encodable, CB1: Encodable>(_ function: @escaping (Target) -> (@escaping (CB0, CB1) -> Void) throws -> Void, as name: String) {
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
    public func bind<CB0: Encodable, CBA1: NSArray>(_ function: @escaping (Target) -> (@escaping (CB0, CBA1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cb0, cba1 in
                _ = try! callable.call(args: [cb0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CB0: Encodable, CBD1: NSDictionary>(_ function: @escaping (Target) -> (@escaping (CB0, CBD1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cb0, cbd1 in
                _ = try! callable.call(args: [cb0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBA0: NSArray, CBA1: NSArray>(_ function: @escaping (Target) -> (@escaping (CBA0, CBA1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cba0, cba1 in
                _ = try! callable.call(args: [cba0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBA0: NSArray, CB1: Encodable>(_ function: @escaping (Target) -> (@escaping (CBA0, CB1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cba0, cb1 in
                _ = try! callable.call(args: [cba0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBA0: NSArray, CBD1: NSDictionary>(_ function: @escaping (Target) -> (@escaping (CBA0, CBD1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cba0, cbd1 in
                _ = try! callable.call(args: [cba0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBD0: NSDictionary, CB1: Encodable>(_ function: @escaping (Target) -> (@escaping (CBD0, CB1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cbd0, cb1 in
                _ = try! callable.call(args: [cbd0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBD0: NSDictionary, CBA1: NSArray>(_ function: @escaping (Target) -> (@escaping (CBD0, CBA1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cbd0, cba1 in
                _ = try! callable.call(args: [cbd0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<CBD0: NSDictionary, CBD1: NSDictionary>(_ function: @escaping (Target) -> (@escaping (CBD0, CBD1) -> Void) throws -> Void, as name: String) {
        let boundFunction = function(target)
        let wrappedFunction = { (callable: Callable) -> Void in
            try boundFunction { cbd0, cbd1 in
                _ = try! callable.call(args: [cbd0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> R, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> NSArray, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1) throws -> NSDictionary, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CB0) -> Void) throws -> Void, as name: String) where A0: Decodable {
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
    public func bind<A0>(_ function: @escaping (Target) -> (A0, @escaping (NSArray) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cba0 in
                _ = try! callable.call(args: [cba0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0>(_ function: @escaping (Target) -> (A0, @escaping (NSDictionary) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cbd0 in
                _ = try! callable.call(args: [cbd0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0: Encodable, CB1: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CB0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable {
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
    public func bind<A0, CB0: Encodable, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, @escaping (CB0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cb0, cba1 in
                _ = try! callable.call(args: [cb0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CB0: Encodable, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, @escaping (CB0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cb0, cbd1 in
                _ = try! callable.call(args: [cb0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBA0: NSArray, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, @escaping (CBA0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cba0, cba1 in
                _ = try! callable.call(args: [cba0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBA0: NSArray, CB1: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CBA0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cba0, cb1 in
                _ = try! callable.call(args: [cba0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBA0: NSArray, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, @escaping (CBA0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cba0, cbd1 in
                _ = try! callable.call(args: [cba0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBD0: NSDictionary, CB1: Encodable>(_ function: @escaping (Target) -> (A0, @escaping (CBD0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cbd0, cb1 in
                _ = try! callable.call(args: [cbd0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBD0: NSDictionary, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, @escaping (CBD0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cbd0, cba1 in
                _ = try! callable.call(args: [cbd0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, CBD0: NSDictionary, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, @escaping (CBD0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, callable: Callable) -> Void in
            try boundFunction(arg0) { cbd0, cbd1 in
                _ = try! callable.call(args: [cbd0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> R, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> NSArray, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2) throws -> NSDictionary, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
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
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1, @escaping (NSArray) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cba0 in
                _ = try! callable.call(args: [cba0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1>(_ function: @escaping (Target) -> (A0, A1, @escaping (NSDictionary) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cbd0 in
                _ = try! callable.call(args: [cbd0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0: Encodable, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
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
    public func bind<A0, A1, CB0: Encodable, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cb0, cba1 in
                _ = try! callable.call(args: [cb0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CB0: Encodable, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, @escaping (CB0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cb0, cbd1 in
                _ = try! callable.call(args: [cb0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBA0: NSArray, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBA0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cba0, cba1 in
                _ = try! callable.call(args: [cba0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBA0: NSArray, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBA0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cba0, cb1 in
                _ = try! callable.call(args: [cba0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBA0: NSArray, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBA0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cba0, cbd1 in
                _ = try! callable.call(args: [cba0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBD0: NSDictionary, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBD0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cbd0, cb1 in
                _ = try! callable.call(args: [cbd0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBD0: NSDictionary, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBD0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cbd0, cba1 in
                _ = try! callable.call(args: [cbd0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, CBD0: NSDictionary, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, @escaping (CBD0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, callable: Callable) -> Void in
            try boundFunction(arg0, arg1) { cbd0, cbd1 in
                _ = try! callable.call(args: [cbd0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> R, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> NSArray, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3) throws -> NSDictionary, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
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
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (NSArray) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cba0 in
                _ = try! callable.call(args: [cba0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (NSDictionary) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cbd0 in
                _ = try! callable.call(args: [cbd0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0: Encodable, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
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
    public func bind<A0, A1, A2, CB0: Encodable, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cb0, cba1 in
                _ = try! callable.call(args: [cb0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CB0: Encodable, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CB0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cb0, cbd1 in
                _ = try! callable.call(args: [cb0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBA0: NSArray, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBA0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cba0, cba1 in
                _ = try! callable.call(args: [cba0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBA0: NSArray, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBA0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cba0, cb1 in
                _ = try! callable.call(args: [cba0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBA0: NSArray, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBA0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cba0, cbd1 in
                _ = try! callable.call(args: [cba0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBD0: NSDictionary, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBD0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cbd0, cb1 in
                _ = try! callable.call(args: [cbd0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBD0: NSDictionary, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBD0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cbd0, cba1 in
                _ = try! callable.call(args: [cbd0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, CBD0: NSDictionary, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, @escaping (CBD0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2) { cbd0, cbd1 in
                _ = try! callable.call(args: [cbd0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<R: Encodable, A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> R, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> NSArray, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, A4>(_ function: @escaping (Target) -> (A0, A1, A2, A3, A4) throws -> NSDictionary, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable, A4: Decodable {
        let boundFunction = function(target)
        let callable = make_callable(boundFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
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
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (NSArray) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cba0 in
                _ = try! callable.call(args: [cba0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (NSDictionary) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cbd0 in
                _ = try! callable.call(args: [cbd0]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cb0, cb1 in
                _ = try! callable.call(args: [cb0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cb0, cba1 in
                _ = try! callable.call(args: [cb0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CB0: Encodable, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CB0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cb0, cbd1 in
                _ = try! callable.call(args: [cb0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBA0: NSArray, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBA0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cba0, cba1 in
                _ = try! callable.call(args: [cba0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBA0: NSArray, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBA0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cba0, cb1 in
                _ = try! callable.call(args: [cba0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBA0: NSArray, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBA0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cba0, cbd1 in
                _ = try! callable.call(args: [cba0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBD0: NSDictionary, CB1: Encodable>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBD0, CB1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cbd0, cb1 in
                _ = try! callable.call(args: [cbd0, cb1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBD0: NSDictionary, CBA1: NSArray>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBD0, CBA1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cbd0, cba1 in
                _ = try! callable.call(args: [cbd0, cba1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }

    /**
     Bind the specified function to this connection.
     */
    public func bind<A0, A1, A2, A3, CBD0: NSDictionary, CBD1: NSDictionary>(_ function: @escaping (Target) -> (A0, A1, A2, A3, @escaping (CBD0, CBD1) -> Void) throws -> Void, as name: String) where A0: Decodable, A1: Decodable, A2: Decodable, A3: Decodable {
        let boundFunction = function(target)
        let wrappedFunction = { (arg0: A0, arg1: A1, arg2: A2, arg3: A3, callable: Callable) -> Void in
            try boundFunction(arg0, arg1, arg2, arg3) { cbd0, cbd1 in
                _ = try! callable.call(args: [cbd0, cbd1]) // swiftlint:disable:this force_try
            }
        }
        let callable = make_callable(wrappedFunction)
        bind(callable, as: name)
    }
}
