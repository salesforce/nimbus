//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.tests

import com.google.common.truth.Truth
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

fun withinLatch(block: CountDownLatch.() -> Unit): CountDownLatch {
    return CountDownLatch(1).apply { block(this) }.also {
        Truth.assertThat(it.await(5, TimeUnit.SECONDS)).isTrue()
    }
}

fun CountDownLatch.withTimeoutInSeconds(timeoutInSeconds: Long, block: () -> Unit) {
    Truth.assertThat(await(timeoutInSeconds, TimeUnit.SECONDS)).isTrue()
    block()
}
