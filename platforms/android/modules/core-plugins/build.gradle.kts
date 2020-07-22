//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    kotlin("kapt")
    id("org.jetbrains.dokka")
}

android {
    setDefaults(project)
}

dependencies {
    implementation(nimbusModule("core"))
    implementation(nimbusModule("annotations"))
    implementation(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
}

apply(from = rootProject.file("gradle/lint.gradle"))
