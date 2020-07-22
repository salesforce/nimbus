//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

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
