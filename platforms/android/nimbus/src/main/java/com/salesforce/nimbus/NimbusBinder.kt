//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

/**
 * Binder interface for the generated [NimbusExtension] binder class.
 */
interface NimbusBinder {

  /**
   * Returns the [NimbusExtension] that this binder is bound to.
   */
  fun getExtension(): NimbusExtension

  /**
   * Returns the name of the extension which will be used as the javascript interface.
   */
  fun getExtensionName(): String
}
