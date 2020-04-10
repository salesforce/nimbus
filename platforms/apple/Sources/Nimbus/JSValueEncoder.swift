//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

// swiftlint:disable file_length

import JavaScriptCore

public class JSValueEncoder {
    public func encode<T>(_ value: T, context: JSContext) throws -> JSValue where T: Encodable {
        let encoder = JSValueEncoderContainer(context: context)
        try value.encode(to: encoder)
        return encoder.resolvedValue()
    }
}

extension JSValue {
    func append(_ value: NSObject) {
        guard self.isArray, let length = self.forProperty("length") else {
            return
        }
        let count = Int(length.toInt32())
        self.setObject(value, atIndexedSubscript: count)
    }

    func append(_ value: NSObject, for key: String) {
        guard self.isObject else {
            return
        }
        self.setObject(value, forKeyedSubscript: key)
    }
}

enum JSValueEncoderError: Error {
    case invalidContext
}

class JSValueEncoderStorage {
    var jsValueContainers: [JSValue] = []
    let context: JSContext
    var count: Int {
        return jsValueContainers.count
    }

    init(context: JSContext) {
        self.context = context
    }

    func push(container: __owned NSObject) {
        self.jsValueContainers.append(JSValue(object: container, in: self.context))
    }

    func pushUnKeyedContainer() throws -> JSValue {
        guard let jsArray = JSValue(newArrayIn: self.context) else {
            throw JSValueEncoderError.invalidContext
        }
        self.jsValueContainers.append(jsArray)
        return jsArray
    }

    func pushKeyedContainer() throws -> JSValue {
        guard let jsDictionary = JSValue(newObjectIn: self.context) else {
            throw JSValueEncoderError.invalidContext
        }
        self.jsValueContainers.append(jsDictionary)
        return jsDictionary
    }

    func popContainer() -> JSValue {
        precondition(!self.jsValueContainers.isEmpty, "Empty container stack.")
        return self.jsValueContainers.popLast()!
    }
}

class JSValueEncoderContainer: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage: JSValueEncoderStorage
    let context: JSContext

    init(context: JSContext) {
        self.context = context
        self.storage = JSValueEncoderStorage(context: context)
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

private class JSValueKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: JSValueEncoderContainer
    let container: JSValue?
    var codingPath: [CodingKey]

    init(encoder: JSValueEncoderContainer, container: JSValue?, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.container = container
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {
        container?.append(NSNull(), for: key.stringValue)
    }

    func encode(_ value: Bool, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: String, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Double, forKey key: K) throws {
        container?.append(try self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Float, forKey key: K) throws {
        container?.append(try self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Int, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Int8, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Int16, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Int32, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: Int64, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: UInt, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        container?.append(self.encoder.box(value), for: key.stringValue)
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        container?.append(try self.encoder.box(value), for: key.stringValue)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
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

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: self.encoder, container: dictionary, codingPath: self.codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
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
            self.container?.append(array, for: containerKey)
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return JSValueUnkeyedEncodingContainer(encoder: self.encoder, container: array, codingPath: self.codingPath)
    }

    func superEncoder() -> Encoder {
        return JSValueEncoderContainer(context: JSContext())
    }

    func superEncoder(forKey key: K) -> Encoder {
        return JSValueEncoderContainer(context: JSContext())
    }

    typealias Key = K

}

private class JSValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let encoder: JSValueEncoderContainer
    let container: JSValue?
    var codingPath: [CodingKey]
    var count: Int

    init(encoder: JSValueEncoderContainer, container: JSValue?, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.container = container
        self.codingPath = codingPath
        count = 0
    }

    func encode(_ value: String) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: Double) throws {
        container?.append(try self.encoder.box(value))
    }

    func encode(_ value: Float) throws {
        container?.append(try self.encoder.box(value))
    }

    func encode(_ value: Int) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: Int8) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: Int16) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: Int32) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: Int64) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: UInt) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: UInt8) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: UInt16) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: UInt32) throws {
        container?.append(self.encoder.box(value))
    }

    func encode(_ value: UInt64) throws {
        container?.append(self.encoder.box(value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        self.encoder.codingPath.append(JSValueKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        container?.append(try self.encoder.box(value))
    }

    func encode(_ value: Bool) throws {
        container?.append(self.encoder.box(value))
    }

    func encodeNil() throws {
        container?.append(NSNull())
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        self.codingPath.append(JSValueKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let dictionary = JSValue(newObjectIn: encoder.context)
        if let dictionary = dictionary {
            self.container?.append(dictionary)
        }

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: encoder, container: dictionary, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(JSValueKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let array = JSValue(newArrayIn: encoder.context)
        if let array = array {
            self.container?.append(array)
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
        storage.push(container: self.box(value))
    }

    func encode(_ value: String) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: Double) throws {
        storage.push(container: try self.box(value))
    }

    func encode(_ value: Float) throws {
        storage.push(container: try self.box(value))
    }

    func encode(_ value: Int) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: Int8) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: Int16) throws {
       storage.push(container: self.box(value))
    }

    func encode(_ value: Int32) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: Int64) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: UInt) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: UInt8) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: UInt16) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: UInt32) throws {
        storage.push(container: self.box(value))
    }

    func encode(_ value: UInt64) throws {
        storage.push(container: self.box(value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        try self.storage.push(container: self.box(value))
    }

}

private struct JSValueKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = JSValueKey(stringValue: "super")!
}

private extension JSValueEncoderContainer {
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    func box(_ value: Bool) -> NSObject { return NSNumber(value: value) }
    func box(_ value: Int) -> NSObject { return NSNumber(value: value) }
    func box(_ value: Int8) -> NSObject { return NSNumber(value: value) }
    func box(_ value: Int16) -> NSObject { return NSNumber(value: value) }
    func box(_ value: Int32) -> NSObject { return NSNumber(value: value) }
    func box(_ value: Int64) -> NSObject { return NSNumber(value: value) }
    func box(_ value: UInt) -> NSObject { return NSNumber(value: value) }
    func box(_ value: UInt8) -> NSObject { return NSNumber(value: value) }
    func box(_ value: UInt16) -> NSObject { return NSNumber(value: value) }
    func box(_ value: UInt32) -> NSObject { return NSNumber(value: value) }
    func box(_ value: UInt64) -> NSObject { return NSNumber(value: value) }
    func box(_ value: String) -> NSObject { return NSString(string: value) }

    func box(_ float: Float) throws -> NSObject {
        return NSNumber(value: float)
    }

    func box(_ double: Double) throws -> NSObject {

        return NSNumber(value: double)
    }

    func box(_ date: Date) throws -> NSObject {
        return NSNumber(value: date.timeIntervalSince1970)
    }

    func box(_ data: Data) throws -> NSObject {
        return NSString(string: data.base64EncodedString())
    }

    func box(_ dict: [String: Encodable]) throws -> NSObject? {
        let depth = self.storage.count
        let result = try self.storage.pushKeyedContainer()
        do {
            for (key, value) in dict {
                self.codingPath.append(JSValueKey(stringValue: key, intValue: nil))
                defer { self.codingPath.removeLast() }
                result.append(try box(value), for: key)
            }
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }

    func box(_ value: Encodable) throws -> NSObject {
        return try self.box_(value) ?? NSDictionary()
    }

    func box_(_ value: Encodable) throws -> NSObject? {
        let type = Swift.type(of: value)
        if type == Date.self || type == NSDate.self {
            return try self.box((value as! Date)) //swiftlint:disable:this force_cast
        } else if type == Data.self || type == NSData.self {
            return try self.box((value as! Data)) //swiftlint:disable:this force_cast
        } else if type == URL.self || type == NSURL.self {
            // Encode URLs as single strings.
            return self.box((value as! URL).absoluteString) //swiftlint:disable:this force_cast
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return (value as! NSDecimalNumber) //swiftlint:disable:this force_cast
        }

        let depth = self.storage.count
        do {
            try value.encode(to: self)
        } catch {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }
}

private class JSValueReferencingEncoder: JSValueEncoderContainer {
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(NSMutableArray, Int)

        /// Referencing a specific key in a dictionary container.
        case dictionary(NSMutableDictionary, String)
    }

    let encoder: JSValueEncoderContainer

    /// The container reference itself.
    private let reference: Reference

    init(referencing encoder: JSValueEncoderContainer, at index: Int, wrapping array: NSMutableArray) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(context: encoder.context)

        self.codingPath.append(JSValueKey(index: index))
    }

    init(referencing encoder: JSValueEncoderContainer, key: CodingKey, convertedKey: __shared CodingKey, wrapping dictionary: NSMutableDictionary) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, convertedKey.stringValue)
        super.init(context: encoder.context)

        self.codingPath.append(key)
    }

    var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }

    deinit {
        let value: Any
        switch self.storage.count {
        case 0: value = NSDictionary()
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case .array(let array, let index):
            array.insert(value, at: index)

        case .dictionary(let dictionary, let key):
            dictionary[NSString(string: key)] = value
        }
    }
}
