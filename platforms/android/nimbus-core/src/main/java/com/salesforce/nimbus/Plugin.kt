//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

/**
 * Defines a plugin which will be bound to the [Bridge]. Implementations of this interface
 * must also be annotated with [PluginOptions].
 */
interface Plugin {

    /**
     * Customize the [JavascriptEngine] prior to the plugin being initialized. Do not add any javascript
     * interfaces to the [JavascriptEngine] here. They will be added by the [Bridge].
     */
    fun <JavascriptEngine> customize(runtime: Runtime<JavascriptEngine>) {
        /* default empty implementation so simple plugins don't need to override */
    }

    /**
     * Do any cleanup of the [JavascriptEngine] necessary for this plugin. Do not remove any javascript
     * interfaces from the [JavascriptEngine] here. They will be removed by the [Bridge].
     */
    fun <JavascriptEngine> cleanup(runtime: Runtime<JavascriptEngine>) {
        /* default empty implementation so simple plugins don't need to override */
    }
}
