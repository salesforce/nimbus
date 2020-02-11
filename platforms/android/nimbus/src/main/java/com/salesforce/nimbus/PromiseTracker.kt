//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus


import java.util.concurrent.ConcurrentHashMap

/**
 * A [PromiseTracker] holds on to registered completion blocks until the Javascript Promise it
 * is associated with resolves or rejects
 */
class PromiseTracker<R>() {
    protected fun finalize() {
        // TODO: call all registered callbacks with errors
    }

    fun register(promiseId: String, promiseCallback: Function2<String?, R?, Void>) {
        // TODO: If the Promise with the given promiseId is already finished, call the promiseCallback now with the finished error and result, and stop tracking the error/result.
        // TODO: Otherwise, if the Promise is not yet finished, hold on to the promiseCallback until finishPromise is called, and call it then.
        // TODO: Tracking/reading of registered callbacks must be thread-safe
    }

    fun finishPromise(promiseId: String, error: String?, result: R?) {
        // TODO: If register has already been called for the given promiseId, call the registered promiseCallback with the given error and result, and stop tracking the callback.
        // TODO: Otherwise, if register has not yet been called, remember the error/result until register is called, and call the callback then.
        // TODO: Tracking/reading of error/result pairs for not-yet-registered Promises must be thread-safe
    }

    /**
     * Generates a callback for passing to callJavascript with "callAwaiting"
     */
    fun registrarFor(promiseCompletion: (String?, R?) -> Void): (Any) -> Unit {
        return { promiseId: Any -> if (promiseId != null) register(promiseId as String, promiseCompletion) }
    }
}
