//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus

import android.webkit.WebView
import java.util.concurrent.ConcurrentHashMap

/**
 * A [PromiseTracker] holds on to registered completion blocks until the Javascript Promise it
 * is associated with resolves or rejects
 */
class PromiseTracker<R>() {
    private val promises: ConcurrentHashMap<String, Function2<String?, R?, Unit>> = ConcurrentHashMap()

    protected fun finalize() {
        promises.values.forEach { it.invoke("Canceled", null) }
        promises.clear()
    }

    fun registerAndInvoke(webView: WebView, promiseId: String, args: Array<JSONSerializable?>, promiseCompletion: Function2<String?, R?, Unit>) {
        promises[promiseId] = promiseCompletion

        webView.callJavascript("__nimbus.callAwaiting", args) { error ->
            if (error != null && error != "null") {
                promises.remove(promiseId)
                promiseCompletion(error as String, null)
            }
        }
    }

    fun finishPromise(promiseId: String, error: String?, result: R?) {
        val promise = promises.remove(promiseId)
        promise?.let {
            promise(if (error == "") null else error, result)
        }
    }
}
