//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import kotlinx.serialization.json.Json

const val NIMBUS_BRIDGE = "__nimbus"
const val NIMBUS_PLUGINS = "plugins"
const val NIMBUS_CLASS_DISCRIMINATOR = "__type"
@Suppress("EXPERIMENTAL_API_USAGE")
val NIMBUS_JSON_TYPE = Json { classDiscriminator = NIMBUS_CLASS_DISCRIMINATOR; encodeDefaults = true }
val NIMBUS_JSON_DEFAULT = Json { encodeDefaults = true }
