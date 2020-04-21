//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

import JavaScriptCore

public class JSValueDecoder {
    public func decode<T>(_ type: T.Type = T.self, from value: JSValue) throws -> T
        where T: Decodable {
        let decoder = JSValueContainer(value: value)
        return try decoder.decode(type)
    }
}

struct JSValueContainer {
    var value: JSValue
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
}

extension JSValueContainer: Decoder {
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        guard value.isObject else {
            throw DecodingError.typeMismatch(
                [String: JSValue].self,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "fail"
                )
            )
        }
        return KeyedDecodingContainer(
            JSObjectValueContainer(
                object: value,
                codingPath: codingPath,
                userInfo: userInfo
            )
        )
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard value.isArray else {
            throw DecodingError.typeMismatch(
                [JSValue].self,
                DecodingError.Context(codingPath: codingPath, debugDescription: "fail")
            )
        }
        return JSArrayValueContainer(array: value, codingPath: codingPath, userInfo: userInfo)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        self
    }
}

extension JSValueContainer: SingleValueDecodingContainer {
    public func decodeNil() -> Bool {
        value.isNull
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        guard value.isBoolean else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }

        return value.toBool()
    }

    public func decode(_ type: String.Type) throws -> String {
        guard value.isString else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        return value.toString()
    }

    public func decode<T>(_ type: T.Type) throws -> T
        where T: Decodable & BinaryFloatingPoint {
        guard value.isNumber else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        return T(value.toNumber().doubleValue)
    }

    public func decode<T>(_ type: T.Type) throws -> T
        where T: Decodable & BinaryInteger {
        guard value.isNumber else {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found null instead."
                )
            )
        }
        guard let result = T(exactly: value.toNumber().doubleValue) else {
            throw DecodingError.typeMismatch(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Unable to represent \(value.toNumber()!) as \(type)"
                )
            )
        }
        return result
    }

    public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try type.init(from: self)
    }
}

struct JSArrayValueContainer {
    let array: JSValue
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    var currentIndex: Int = 0
}

extension JSArrayValueContainer: UnkeyedDecodingContainer {
    var count: Int? {
        return array.forProperty("length")!.toNumber().intValue
    }

    var isAtEnd: Bool {
        return currentIndex == count
    }

    @inlinable
    func guardNotAtEnd<T>(_ type: T.Type) throws {
        if isAtEnd {
            throw DecodingError.valueNotFound(
                type,
                DecodingError.Context(
                    codingPath: codingPath + [JSValueKey(intValue: currentIndex)],
                    debugDescription: "End of unkeyed container reached"
                )
            )
        }
    }

    mutating func decodeNil() throws -> Bool {
        try guardNotAtEnd(JSValue.self)
        if array.atIndex(currentIndex).isNull {
            currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try guardNotAtEnd(type)
        let decoder = JSValueContainer(
            value: array.atIndex(currentIndex),
            codingPath: codingPath + [JSValueKey(intValue: currentIndex)]
        )
        let value = try decoder.decode(type)
        currentIndex += 1
        return value
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try guardNotAtEnd(KeyedDecodingContainer<NestedKey>.self)
        let value = array.atIndex(currentIndex)!
        guard value.isObject else {
            throw
                DecodingError.valueNotFound(
                    KeyedDecodingContainer<NestedKey>.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Cannot get keyed decoding container -- found null value instead."
                    )
                )
        }
        currentIndex += 1
        return KeyedDecodingContainer(
            JSObjectValueContainer(
                object: value,
                codingPath: codingPath + [JSValueKey(intValue: currentIndex)],
                userInfo: userInfo
            )
        )
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try guardNotAtEnd(UnkeyedDecodingContainer.self)
        let value = array.atIndex(currentIndex)!
        guard value.isArray else {
            throw
                DecodingError.valueNotFound(
                    UnkeyedDecodingContainer.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Cannot get unkeyed decoding container -- found null value instead."
                    )
                )
        }
        currentIndex += 1
        return JSArrayValueContainer(
            array: value,
            codingPath: codingPath + [JSValueKey(intValue: currentIndex)],
            userInfo: userInfo
        )
    }

    mutating func superDecoder() throws -> Decoder {
        try guardNotAtEnd(Decoder.self)
        let value = array.atIndex(currentIndex)!
        currentIndex += 1
        return JSValueContainer(value: value, codingPath: codingPath + [JSValueKey(intValue: currentIndex)])
    }
}

struct JSObjectValueContainer<K: CodingKey> {
    let object: JSValue
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
}

extension JSObjectValueContainer: KeyedDecodingContainerProtocol {
    typealias Key = K

    var allKeys: [K] {
        let objectKeys = object.context.evaluateScript("Object.keys")!
        let keys = objectKeys.call(withArguments: [object]).toArray() as? [String] ?? []
        return keys.compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: K) -> Bool {
        object.hasProperty(key.stringValue)
    }

    func guardNil(forKey key: K) throws -> JSValue {
        guard let value = object.forProperty(key.stringValue) else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "No value associated with key \(key.stringValue)."
                )
            )
        }

        return value
    }

    func decodeNil(forKey key: K) throws -> Bool {
        let value = try guardNil(forKey: key)
        return value.isNull
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let value = try guardNil(forKey: key)
        return try JSValueContainer(
            value: value,
            codingPath: codingPath + [key]
        ).decode(type)
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        guard let value = object.forProperty(key.stringValue) else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key.stringValue)"
                )
            )
        }
        guard value.isObject else {
            throw DecodingError.typeMismatch(
                [String: JSValue].self,
                DecodingError.Context(
                    codingPath: codingPath + [key],
                    debugDescription: "Expected an object, found \(type(of: value))"
                )
            )
        }
        return KeyedDecodingContainer(
            JSObjectValueContainer<NestedKey>(
                object: value,
                codingPath: codingPath + [key],
                userInfo: userInfo
            )
        )
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        guard let value = object.forProperty(key.stringValue) else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \(key.stringValue)"
                )
            )
        }
        guard value.isArray else {
            throw DecodingError.typeMismatch(
                [Any].self,
                DecodingError.Context(codingPath: codingPath + [key], debugDescription: "Expected an array, found \(type(of: value))")
            )
        }
        return JSArrayValueContainer(
            array: value,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }

    func superDecoder() throws -> Decoder {
        let value: JSValue = object.forProperty(JSValueKey.super.stringValue)
        return JSValueContainer(
            value: value,
            codingPath: codingPath + [JSValueKey.super]
        )
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        let value: JSValue = object.forProperty(key.stringValue)
        return JSValueContainer(
            value: value,
            codingPath: codingPath + [JSValueKey(stringValue: key.stringValue)]
        )
    }
}

private struct JSValueKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    fileprivate static let `super` = JSValueKey(stringValue: "super")
}
