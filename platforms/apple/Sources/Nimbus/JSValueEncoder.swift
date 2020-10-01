//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo
// root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable file_length

import JavaScriptCore

/**
 An `Encoder` class for encoding `Encodable` types to `JSValue` instances.
 */
public class JSValueEncoder {
    public init() {}

    /**
     Attempt to encode the given object to a `JSValue`.
     */
    public func encode<T>(_ value: T, context: JSContext) throws -> JSValue where T: Encodable {
        let encoder = JSValueEncoderContainer(context: context)
        try value.encode(to: encoder)
        return encoder.resolvedValue()
    }
}

enum JSValueEncoderError: Error {
    case invalidContext
}

struct JSValueEncoderStorage {
    var jsValueContainers: [JSValue] = []
    let context: JSContext
    var count: Int {
        return jsValueContainers.count
    }

    init(context: JSContext) {
        self.context = context
    }

    mutating func push(container: __owned Any) {
        jsValueContainers.append(JSValue(object: container, in: context))
    }

    mutating func pushUnKeyedContainer() throws -> JSValue {
        guard let jsArray = JSValue(newArrayIn: self.context) else {
            throw JSValueEncoderError.invalidContext
        }
        jsValueContainers.append(jsArray)
        return jsArray
    }

    mutating func pushKeyedContainer() throws -> JSValue {
        guard let jsDictionary = JSValue(newObjectIn: self.context) else {
            throw JSValueEncoderError.invalidContext
        }
        jsValueContainers.append(jsDictionary)
        return jsDictionary
    }

    mutating func popContainer() -> JSValue {
        precondition(!jsValueContainers.isEmpty, "Empty container stack.")
        return jsValueContainers.popLast()!
    }
}

class JSValueEncoderContainer: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage: JSValueEncoderStorage
    let context: JSContext

    init(userInfo: [CodingUserInfoKey: Any] = [:], codingPath: [CodingKey] = [], context: JSContext) {
        self.context = context
        storage = JSValueEncoderStorage(context: context)
    }

    fileprivate func encoder(for key: CodingKey) -> ReferencingEncoder {
        return .init(referencing: self, key: key)
    }

    fileprivate func encoder(at index: Int) -> ReferencingEncoder {
        return .init(referencing: self, at: index)
    }

    func resolvedValue() -> JSValue {
        if storage.count == 1, let main = storage.jsValueContainers.first {
            return main
        }
        return JSValue(object: storage.jsValueContainers, in: context)
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let containerStorage = (try? storage.pushKeyedContainer()) ?? JSValue(newObjectIn: context)
        let container = JSValueKeyedEncodingContainer<Key>(encoder: self, container: containerStorage, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        let containerStorage = (try? storage.pushUnKeyedContainer()) ?? JSValue(newArrayIn: context)
        let container = JSValueUnkeyedEncodingContainer(encoder: self, container: containerStorage, codingPath: codingPath)
        return container
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

struct JSValueKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: JSValueEncoderContainer
    let container: JSValue?
    var codingPath: [CodingKey]

    init(encoder: JSValueEncoderContainer, container: JSValue?, codingPath: [CodingKey]) {
        self.encoder = encoder
        if (container?.isObject ?? false) == true {
            self.container = container
        } else {
            self.container = nil
        }
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {
        container?.append(NSNull(), for: key.stringValue)
    }

    func encode(_ value: Bool, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: String, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Double, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Float, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Int, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Int8, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Int16, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Int32, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: Int64, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: UInt, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        container?.append(value, for: key.stringValue)
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let depth = encoder.storage.count
        do {
            try value.encode(to: encoder)
        } catch {
            if encoder.storage.count > depth {
                _ = encoder.storage.popContainer()
            }
            throw error
        }

        guard encoder.storage.count > depth else {
            return
        }
        container?.append(encoder.storage.popContainer(), for: key.stringValue)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey { // swiftlint:disable:this line_length
        let containerKey = key.stringValue
        let dictionary: JSValue
        if let existingContainer = container?.objectForKeyedSubscript(containerKey) {
            precondition(
                existingContainer.isObject,
                "Attempt to re-encode into nested KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: non-keyed container already encoded for this key"
            )
            dictionary = existingContainer
        } else {
            dictionary = JSValue(newObjectIn: encoder.context)
            self.container?.append(dictionary, for: containerKey)
        }

        codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: encoder, container: dictionary, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let containerKey = key.stringValue
        let array: JSValue
        if let existingContainer = container?.objectForKeyedSubscript(containerKey) {
            precondition(
                existingContainer.isArray,
                "Attempt to re-encode into nested UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: keyed container/single value already encoded for this key"
            )
            array = existingContainer
        } else {
            array = JSValue(newArrayIn: encoder.context)
            container?.append(array, for: containerKey)
        }

        codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return JSValueUnkeyedEncodingContainer(encoder: encoder, container: array, codingPath: codingPath)
    }

    func superEncoder() -> Encoder {
        return encoder(for: JSValueKey.super)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return encoder(for: key)
    }

    private func encoder(for key: CodingKey) -> ReferencingEncoder {
        return encoder.encoder(for: key)
    }

    typealias Key = K
}

struct JSValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let encoder: JSValueEncoderContainer
    let container: JSValue?
    var codingPath: [CodingKey]
    var count: Int

    init(encoder: JSValueEncoderContainer, container: JSValue?, codingPath: [CodingKey]) {
        self.encoder = encoder
        if (container?.isArray ?? false) == true {
            self.container = container
        } else {
            self.container = nil
        }
        self.codingPath = codingPath
        count = 0
    }

    func encode(_ value: String) throws {
        container?.append(value)
    }

    func encode(_ value: Double) throws {
        container?.append(value)
    }

    func encode(_ value: Float) throws {
        container?.append(value)
    }

    func encode(_ value: Int) throws {
        container?.append(value)
    }

    func encode(_ value: Int8) throws {
        container?.append(value)
    }

    func encode(_ value: Int16) throws {
        container?.append(value)
    }

    func encode(_ value: Int32) throws {
        container?.append(value)
    }

    func encode(_ value: Int64) throws {
        container?.append(value)
    }

    func encode(_ value: UInt) throws {
        container?.append(value)
    }

    func encode(_ value: UInt8) throws {
        container?.append(value)
    }

    func encode(_ value: UInt16) throws {
        container?.append(value)
    }

    func encode(_ value: UInt32) throws {
        container?.append(value)
    }

    func encode(_ value: UInt64) throws {
        container?.append(value)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        encoder.codingPath.append(JSValueKey(index: count))
        defer { self.encoder.codingPath.removeLast() }
        let depth = encoder.storage.count
        do {
            try value.encode(to: encoder)
        } catch {
            if encoder.storage.count > depth {
                _ = encoder.storage.popContainer()
            }
            throw error
        }
        guard encoder.storage.count > depth else {
            return
        }
        let containerToAppend = encoder.storage.popContainer()
        container?.append(containerToAppend)
    }

    func encode(_ value: Bool) throws {
        container?.append(value)
    }

    func encodeNil() throws {
        container?.append(NSNull())
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        codingPath.append(JSValueKey(index: count))
        defer { self.codingPath.removeLast() }

        let dictionary = JSValue(newObjectIn: encoder.context)
        if let dictionary = dictionary {
            self.container?.append(dictionary)
        }

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: encoder, container: dictionary, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(JSValueKey(index: count))
        defer { self.codingPath.removeLast() }

        let array = JSValue(newArrayIn: encoder.context)
        if let array = array {
            container?.append(array)
        }
        return JSValueUnkeyedEncodingContainer(encoder: encoder, container: array, codingPath: codingPath)
    }

    func superEncoder() -> Encoder {
        return JSValueEncoderContainer(context: JSContext())
    }
}

extension JSValueEncoderContainer: SingleValueEncodingContainer {
    func encodeNil() throws {
        storage.push(container: NSNull())
    }

    func encode(_ value: Bool) throws {
        storage.push(container: value)
    }

    func encode(_ value: String) throws {
        storage.push(container: value)
    }

    func encode(_ value: Double) throws {
        storage.push(container: value)
    }

    func encode(_ value: Float) throws {
        storage.push(container: value)
    }

    func encode(_ value: Int) throws {
        storage.push(container: value)
    }

    func encode(_ value: Int8) throws {
        storage.push(container: value)
    }

    func encode(_ value: Int16) throws {
        storage.push(container: value)
    }

    func encode(_ value: Int32) throws {
        storage.push(container: value)
    }

    func encode(_ value: Int64) throws {
        storage.push(container: value)
    }

    func encode(_ value: UInt) throws {
        storage.push(container: value)
    }

    func encode(_ value: UInt8) throws {
        storage.push(container: value)
    }

    func encode(_ value: UInt16) throws {
        storage.push(container: value)
    }

    func encode(_ value: UInt32) throws {
        storage.push(container: value)
    }

    func encode(_ value: UInt64) throws {
        storage.push(container: value)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        storage.push(container: value)
    }
}

private struct JSValueKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(index: Int) {
        stringValue = "Index \(index)"
        intValue = index
    }

    static let `super` = JSValueKey(stringValue: "super")!
}

extension JSValue {
    func push(_ values: [Any]) {
        invokeMethod("push", withArguments: values)
    }

    func append(_ value: Any) {
        if let value = JSValue(object: value, in: context) {
            push([value])
        }
    }

    func append(_ value: Any, for key: String) {
        if let value = JSValue(object: value, in: context) {
            setObject(value, forKeyedSubscript: key)
        }
    }
}

private class ReferencingEncoder: JSValueEncoderContainer {
    private enum Reference { case mapping(String), sequence(Int) }

    private let encoder: JSValueEncoderContainer
    private let reference: Reference

    init(referencing encoder: JSValueEncoderContainer, key: CodingKey) {
        self.encoder = encoder
        reference = .mapping(key.stringValue)
        super.init(userInfo: encoder.userInfo, codingPath: encoder.codingPath + [key], context: encoder.context)
    }

    init(referencing encoder: JSValueEncoderContainer, at index: Int) {
        self.encoder = encoder
        reference = .sequence(index)
        super.init(userInfo: encoder.userInfo, codingPath: encoder.codingPath + [JSValueKey(index: index)], context: encoder.context)
    }

    deinit {
        guard let appendTo = encoder.storage.jsValueContainers.last else { return }
        let toAppend = self.storage.popContainer()
        switch reference {
        case let .mapping(key):
            appendTo.setObject(toAppend, forKeyedSubscript: key)

        case let .sequence(index):
            appendTo.setValue(toAppend, at: index)
        }
    }
}
