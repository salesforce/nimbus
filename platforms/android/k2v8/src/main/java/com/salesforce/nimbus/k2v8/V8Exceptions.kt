package com.salesforce.nimbus.k2v8

import kotlinx.serialization.SerializationException
import kotlin.reflect.KClass

/**
 * Generic exception indicating a problem with V8 serialization and deserialization.
 */
open class V8Exception(message: String) : SerializationException(message)

/**
 * Thrown when [K2V8] has failed to create a V8Object from the given value.
 */
class V8EncodingException(message: String) : V8Exception(message)

/**
 * Thrown when [K2V8] has failed to decode a V8Object.
 */
class V8DecodingException(message: String) : V8Exception(message)

internal fun invalidValueTypeEncodingException(kClass: KClass<*>) = V8EncodingException(
    "Unable to encode value of type '${kClass.qualifiedName}'"
)

internal fun invalidKeyTypeEncodingException(kClass: KClass<*>) = V8EncodingException(
    "Value of type '${kClass.qualifiedName}' can't be used in V8 as a key in the map. " +
        "Only String or Enum types are allowed."
)

internal fun invalidValueTypeDecodingException(kClass: KClass<*>) = V8DecodingException(
    "Unable to decode value of type '${kClass.qualifiedName}."
)
