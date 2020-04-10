//
//  JSValueEncoder.swift
//  Nimbus
//
//  Created by Paul Tiarks on 4/7/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

import JavaScriptCore

public class JSValueEncoder {
    public func encode<T>(_ value: T, context: JSContext) throws -> JSValue where T: Encodable {
        let encoder = JSValueEncoderContainer(context: context)
        try value.encode(to: encoder)
        return encoder.resolvedValue()
    }
}

class JSValueEncoderStorage {
    var containers: [AnyObject] = []
    var count: Int {
        return containers.count
    }

    func push(container: __owned NSObject) {
        self.containers.append(container)
    }

    func pushUnKeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        self.containers.append(array)
        return array
    }

    func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        self.containers.append(dictionary)
        return dictionary
    }
}

class JSValueEncoderContainer: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage: JSValueEncoderStorage
    let context: JSContext

    init(context: JSContext) {
        self.context = context
        self.storage = JSValueEncoderStorage()
    }

    func resolvedValue() -> JSValue {
        if storage.count == 1, let main = storage.containers.first {
            return JSValue(object: main, in: context)
        }
        return JSValue(object: storage.containers, in: context)
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let containerStorage = storage.pushKeyedContainer()
        let container = JSValueKeyedEncodingContainer<Key>(encoder: self, container: containerStorage, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        let containerStorage = storage.pushUnKeyedContainer()
        let container = JSValueUnkeyedEncodingContainer(encoder: self, container: containerStorage, codingPath: codingPath)
        return container
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

private class JSValueKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: JSValueEncoderContainer
    let container: NSMutableDictionary
    var codingPath: [CodingKey]

    init(encoder: JSValueEncoderContainer, container: NSMutableDictionary, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.container = container
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {
        self.container[key.stringValue] = NSNull()
    }

    func encode(_ value: Bool, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: String, forKey key: K) throws {
        self.container[key.stringValue] = value as NSString
    }

    func encode(_ value: Double, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Float, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Int, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Int8, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Int16, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Int32, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: Int64, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: UInt, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        self.container[key.stringValue] = NSNumber(value: value)
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        self.container[key.stringValue] = value
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let containerKey = key.stringValue
        let dictionary: NSMutableDictionary
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is NSMutableDictionary,
                "Attempt to re-encode into nested KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: non-keyed container already encoded for this key"
            )
            dictionary = existingContainer as! NSMutableDictionary // swiftlint:disable:this force_cast
        } else {
            dictionary = NSMutableDictionary()
            self.container[containerKey] = dictionary
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: self.encoder, container: dictionary, codingPath: self.codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let containerKey = key.stringValue
        let array: NSMutableArray
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is NSMutableArray,
                "Attempt to re-encode into nested UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: keyed container/single value already encoded for this key"
            )
            array = existingContainer as! NSMutableArray //swiftlint:disable:this force_cast
        } else {
            array = NSMutableArray()
            self.container[containerKey] = array
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
    let container: NSMutableArray
    var codingPath: [CodingKey]
    var count: Int

    init(encoder: JSValueEncoderContainer, container: NSMutableArray, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.container = container
        self.codingPath = codingPath
        count = 0
    }

    func encode(_ value: String) throws {
        container.add(value)
    }

    func encode(_ value: Double) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Float) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Int) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Int8) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Int16) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Int32) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: Int64) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: UInt) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: UInt8) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: UInt16) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: UInt32) throws {
        container.add(NSNumber(value: value))
    }

    func encode(_ value: UInt64) throws {
        container.add(NSNumber(value: value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        container.add(value)
    }

    func encode(_ value: Bool) throws {
        container.add(NSNumber(value: value))
    }

    func encodeNil() throws {
        container.add(NSNull())
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        self.codingPath.append(JSValueKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let dictionary = NSMutableDictionary()
        self.container.add(dictionary)

        let container = JSValueKeyedEncodingContainer<NestedKey>(encoder: encoder, container: dictionary, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(JSValueKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let array = NSMutableArray()
        self.container.add(array)
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
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: String) throws {
        storage.push(container: value as NSString)
    }

    func encode(_ value: Double) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Float) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Int) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Int8) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Int16) throws {
       storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Int32) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: Int64) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: UInt) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: UInt8) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: UInt16) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: UInt32) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode(_ value: UInt64) throws {
        storage.push(container: NSNumber(value: value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        NSLog("single value encode")
    }

}

private struct JSValueKey : CodingKey {
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
