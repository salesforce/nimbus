//
//  JSValueEncoder.swift
//  Nimbus
//
//  Created by Paul Tiarks on 4/7/20.
//  Copyright © 2020 Salesforce.com, inc. All rights reserved.
//

// swiftlint:disable line_length

import JavaScriptCore

public class JSValueEncoder {
    public func encode<T>(_ value: T, context: JSContext) throws -> JSValue where T: Encodable {
        let encoder = JSValueEncoderContainer(value: value, context: context)
        try value.encode(to: encoder)
        return encoder.encodedValue
    }
}

struct JSValueEncoderContainer<T: Encodable>: Encoder {
    var value: T
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var encodedValue: JSValue

    init(value: T, context: JSContext) {
        self.value = value
        self.encodedValue = JSValue(newObjectIn: context)
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = JSValueKeyedEncodingContainer<Key>(codingPath: codingPath, encodedValue: encodedValue)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = JSValueUnkeyedEncodingContainer(encodedValue: encodedValue, codingPath: codingPath, count: 0)
        return container
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

private struct JSValueKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey]
    let encodedValue: JSValue

    mutating func encodeNil(forKey key: K) throws {

    }

    mutating func encode(_ value: Bool, forKey key: K) throws {

    }

    mutating func encode(_ value: String, forKey key: K) throws {

    }

    mutating func encode(_ value: Double, forKey key: K) throws {

    }

    mutating func encode(_ value: Float, forKey key: K) throws {

    }

    mutating func encode(_ value: Int, forKey key: K) throws {

    }

    mutating func encode(_ value: Int8, forKey key: K) throws {

    }

    mutating func encode(_ value: Int16, forKey key: K) throws {

    }

    mutating func encode(_ value: Int32, forKey key: K) throws {

    }

    mutating func encode(_ value: Int64, forKey key: K) throws {

    }

    mutating func encode(_ value: UInt, forKey key: K) throws {

    }

    mutating func encode(_ value: UInt8, forKey key: K) throws {

    }

    mutating func encode(_ value: UInt16, forKey key: K) throws {

    }

    mutating func encode(_ value: UInt32, forKey key: K) throws {

    }

    mutating func encode(_ value: UInt64, forKey key: K) throws {

    }

    mutating func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {

    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = JSValueKeyedEncodingContainer<NestedKey>(codingPath: codingPath, encodedValue: encodedValue)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return JSValueUnkeyedEncodingContainer(encodedValue: encodedValue, codingPath: codingPath, count: 0)
    }

    mutating func superEncoder() -> Encoder {
        return JSValueEncoderContainer(value: 5, context: encodedValue.context)
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        return JSValueEncoderContainer(value: 5, context: encodedValue.context)
    }

    typealias Key = K

}

private struct JSValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let encodedValue: JSValue

    mutating func encode(_ value: String) throws {

    }

    mutating func encode(_ value: Double) throws {

    }

    mutating func encode(_ value: Float) throws {

    }

    mutating func encode(_ value: Int) throws {

    }

    mutating func encode(_ value: Int8) throws {

    }

    mutating func encode(_ value: Int16) throws {

    }

    mutating func encode(_ value: Int32) throws {

    }

    mutating func encode(_ value: Int64) throws {

    }

    mutating func encode(_ value: UInt) throws {

    }

    mutating func encode(_ value: UInt8) throws {

    }

    mutating func encode(_ value: UInt16) throws {

    }

    mutating func encode(_ value: UInt32) throws {

    }

    mutating func encode(_ value: UInt64) throws {

    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {

    }

    mutating func encode(_ value: Bool) throws {

    }

    var codingPath: [CodingKey]

    var count: Int

    mutating func encodeNil() throws {

    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let container = JSValueKeyedEncodingContainer<NestedKey>(codingPath: codingPath, encodedValue: encodedValue)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return JSValueUnkeyedEncodingContainer(encodedValue: encodedValue, codingPath: codingPath, count: 0)
    }

    mutating func superEncoder() -> Encoder {
        return JSValueEncoderContainer(value: 5, context: encodedValue.context)
    }
}

extension JSValueEncoderContainer: SingleValueEncodingContainer {
    mutating func encodeNil() throws {

    }

    mutating func encode(_ value: Bool) throws {

    }

    mutating func encode(_ value: String) throws {

    }

    mutating func encode(_ value: Double) throws {

    }

    mutating func encode(_ value: Float) throws {

    }

    mutating func encode(_ value: Int) throws {

    }

    mutating func encode(_ value: Int8) throws {

    }

    mutating func encode(_ value: Int16) throws {

    }

    mutating func encode(_ value: Int32) throws {

    }

    mutating func encode(_ value: Int64) throws {

    }

    mutating func encode(_ value: UInt) throws {

    }

    mutating func encode(_ value: UInt8) throws {

    }

    mutating func encode(_ value: UInt16) throws {

    }

    mutating func encode(_ value: UInt32) throws {

    }

    mutating func encode(_ value: UInt64) throws {

    }

    mutating func encode<T>(_ value: T) throws where T: Encodable {

    }

}
