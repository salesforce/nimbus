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
        let encoder = JSValueEncoderContainer(value: value, context: context)
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
}

class JSValueEncoderContainer<T: Encodable>: Encoder {
    var value: T
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage: JSValueEncoderStorage
    let context: JSContext

    init(value: T, context: JSContext) {
        self.value = value
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
        let container = JSValueKeyedEncodingContainer<Key>(storage: storage, context: context, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = JSValueUnkeyedEncodingContainer(storage: storage, context: context)
        return container
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

private class JSValueKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey]
    let context: JSContext
    let storage: JSValueEncoderStorage

    init(storage: JSValueEncoderStorage, context: JSContext, codingPath: [CodingKey]) {
        self.context = context
        self.storage = storage
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {

    }

    func encode(_ value: Bool, forKey key: K) throws {

    }

    func encode(_ value: String, forKey key: K) throws {

    }

    func encode(_ value: Double, forKey key: K) throws {

    }

    func encode(_ value: Float, forKey key: K) throws {

    }

    func encode(_ value: Int, forKey key: K) throws {

    }

    func encode(_ value: Int8, forKey key: K) throws {

    }

    func encode(_ value: Int16, forKey key: K) throws {

    }

    func encode(_ value: Int32, forKey key: K) throws {

    }

    func encode(_ value: Int64, forKey key: K) throws {

    }

    func encode(_ value: UInt, forKey key: K) throws {

    }

    func encode(_ value: UInt8, forKey key: K) throws {

    }

    func encode(_ value: UInt16, forKey key: K) throws {

    }

    func encode(_ value: UInt32, forKey key: K) throws {

    }

    func encode(_ value: UInt64, forKey key: K) throws {

    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {

    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = JSValueKeyedEncodingContainer<NestedKey>(storage: storage, context: context, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return JSValueUnkeyedEncodingContainer(storage: storage, context: context)
    }

    func superEncoder() -> Encoder {
        return JSValueEncoderContainer(value: 5, context: context)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return JSValueEncoderContainer(value: 5, context: context)
    }

    typealias Key = K

}

private class JSValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var storage: JSValueEncoderStorage
    var arrayStorage: NSMutableArray
    let context: JSContext
    var codingPath: [CodingKey]
    var count: Int

    init(storage: JSValueEncoderStorage, context: JSContext) {
        self.storage = storage
        self.arrayStorage = self.storage.pushUnKeyedContainer()
        self.context = context
        codingPath = []
        count = 0
    }

    func encode(_ value: String) throws {
        arrayStorage.add(value)
    }

    func encode(_ value: Double) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Float) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Int) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Int8) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Int16) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Int32) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: Int64) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: UInt) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: UInt8) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: UInt16) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: UInt32) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode(_ value: UInt64) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        arrayStorage.add(value)
    }

    func encode(_ value: Bool) throws {
        arrayStorage.add(NSNumber(value: value))
    }

    func encodeNil() throws {
        arrayStorage.add(NSNull())
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = JSValueKeyedEncodingContainer<NestedKey>(storage: storage, context: context, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return JSValueUnkeyedEncodingContainer(storage: storage, context: context)
    }

    func superEncoder() -> Encoder {
        return JSValueEncoderContainer(value: 5, context: context)
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
