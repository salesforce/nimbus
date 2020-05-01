package com.salesforce.nimbus

/**
 * Defines an object that can be encoded to a javascript representation where the
 * [EncodedType] is the encoded type the javascript engine expects
 */
interface JSEncodable<EncodedType> {

    /**
     * Encodes the value to the [EncodedType]
     */
    fun encode(): EncodedType
}
