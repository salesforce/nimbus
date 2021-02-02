//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

rootProject.name = "Nimbus"

arrayOf(
    ":bridge-webview", ":annotations", ":compiler-webview", ":core",
    ":compiler-base", ":bridge-v8", ":compiler-v8", ":core-plugins"
).forEach { include(":modules$it") }

include(":demo-app", ":shared-tests")

// if (file("../../../k2v8").exists()) {
//     logger.lifecycle("Detected local k2v8, building from source.")
//     includeBuild("../../../k2v8")
// }
