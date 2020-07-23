//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

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
