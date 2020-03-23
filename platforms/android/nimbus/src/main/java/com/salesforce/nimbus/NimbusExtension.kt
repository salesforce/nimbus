//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView

/**
 * Defines an extension which will be bound to the [Bridge]. Implementations of this interface
 * must also be annotated with [PluginOptions].
 */
@Deprecated("Use the `Plugin` interface instead.")
interface NimbusExtension : Plugin {

    /**
     * Customize the [WebView] prior to the extension being initialized. Do not add any javascript
     * interfaces to the [WebView] here. They will be added by the [Bridge].
     */
    fun customize(webView: WebView) {
        /* default empty implementation so simple extensions don't need to override */
    }

    override fun customize(webView: WebView, bridge: Bridge) {
        customize(webView)
    }

    /**
     * Do any cleanup of the [WebView] necessary for this extension. Do not remove any javascript
     * interfaces from the [WebView] here. They will be removed by the [Bridge].
     */
    fun cleanup(webView: WebView) {
        /* default empty implementation so simple extensions don't need to override */
    }

    override fun cleanup(webView: WebView, bridge: Bridge) {
        cleanup(webView)
    }
}
