//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.JsonConfiguration

const val NIMBUS_BRIDGE = "__nimbus"
const val NIMBUS_PLUGINS = "plugins"
const val NIMBUS_CLASS_DISCRIMINATOR = "__type"
@UnstableDefault
val NIMBUS_JSON_CONFIGURATION = JsonConfiguration(classDiscriminator = NIMBUS_CLASS_DISCRIMINATOR)
