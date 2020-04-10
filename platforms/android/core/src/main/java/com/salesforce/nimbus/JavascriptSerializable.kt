package com.salesforce.nimbus

/**
 * Defines an object that can be serialized into a javascript representation where the
 * [SerializedOutputType] is the serialized type the javascript engine expects
 */
interface JavascriptSerializable<SerializedOutputType> {

    /**
     * Serializes the value to the [SerializedOutputType]
     */
    fun serialize(): SerializedOutputType
}
