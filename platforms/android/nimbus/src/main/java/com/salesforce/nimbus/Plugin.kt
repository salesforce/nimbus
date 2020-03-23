//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView

/**
 * Defines a plugin which will be bound to the [Bridge]. Implementations of this interface
 * must also be annotated with [PluginOptions].
 */
interface Plugin {
    /**
     * Customize the [WebView] prior to the plugin being initialized. Do not add any javascript
     * interfaces to the [WebView] here. They will be added by the [Bridge].
     */
    fun customize(webView: WebView, bridge: Bridge) {
        /* default empty implementation so simple plugins don't need to override */
    }

    /**
     * Do any cleanup of the [WebView] necessary for this plugin. Do not remove any javascript
     * interfaces from the [WebView] here. They will be removed by the [Bridge].
     */
    fun cleanup(webView: WebView, bridge: Bridge) {
        /* default empty implementation so simple plugins don't need to override */
    }
}
