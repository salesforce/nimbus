//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults(project)
}

dependencies {
    implementation(nimbusModule("annotations"))
    api(nimbusModule("core"))
    kapt(nimbusModule("compiler-webview"))

    api(Libs.kotlinStdlib)

    testImplementation(Libs.junit)
    testImplementation(Libs.json)
    testImplementation(Libs.mockk)
    androidTestImplementation(Libs.mockkAndroid)
    kaptTest(nimbusModule("compiler-webview"))

    kaptAndroidTest(nimbusModule("compiler-webview"))
}

addTestDependencies()

apply(from = rootProject.file("gradle/android-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
