//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView

/**
 * Binder interface for the generated [Plugin] binder class.
 */
interface Binder {

    /**
     * Returns the [Plugin] that this binder is bound to.
     */
    fun getPlugin(): Plugin

    /**
     * Returns the name of the plugin which will be used as the javascript interface.
     */
    fun getPluginName(): String

    /**
     * Sets the [WebView] on the binder so it can make internal calls to it.
     */
    fun setWebView(webView: WebView?)
}
