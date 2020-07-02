package com.salesforce.nimbus

/**
 * Defines an event that can be published by an [EventPublisher].
 *
 * NOTE: The class which implements this interface must also be [Serializable].
 */
interface Event {

    /**
     * The name of the event which is used when subscribing via [EventPublisher.addListener].
     */
    val name: String
}
