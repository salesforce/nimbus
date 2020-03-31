//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

/**
 * Binder interface for the generated [Plugin] binder class. [JavascriptEngine] represents the
 * class which is capable of executing javascript, such as an Android WebView or V8.
 */
interface Binder<JavascriptEngine> {

    /**
     * Returns the [Plugin] that this binder is bound to.
     */
    fun getPlugin(): Plugin

    /**
     * Returns the name of the plugin which will be used as the javascript interface.
     */
    fun getPluginName(): String

    /**
     * Binds to the [Runtime].
     */
    fun bind(runtime: Runtime<JavascriptEngine>)

    /**
     * Unbinds from the [JavascriptEngine].
     */
    fun unbind()
}
