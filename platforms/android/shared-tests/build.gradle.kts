//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

plugins {
    id("com.android.library")
    id("kotlin-android")
    id("kotlin-kapt")
    id("kotlinx-serialization")
    id("com.github.node-gradle.node") version Versions.nodeGradle
}

android {
    setDefaults(project)

    sourceSets.getByName("androidTest") {
        assets.srcDirs("../../../packages/test-www/dist", "../../../packages/nimbus-bridge/dist/iife")
    }
}

dependencies {
    androidTestImplementation(nimbusModule("annotations"))
    androidTestImplementation(nimbusModule("bridge-v8"))
    androidTestImplementation(nimbusModule("bridge-webview"))
    androidTestImplementation(nimbusModule("core"))
    kaptAndroidTest(nimbusModule("compiler-webview"))
    kaptAndroidTest(nimbusModule("compiler-v8"))
    androidTestImplementation(Libs.androidxTestRules) {
        exclude("com.android.support", "support-annotations")
    }
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.guava)
    androidTestImplementation(Libs.j2v8)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.k2v8)
    androidTestImplementation(Libs.kotlinxSerializationRuntime)
    androidTestImplementation(Libs.truth)
}

node {
    // try to use global instead of always downloading it
    download = false
}

/*
 * Compile the test web app prior to assembling the androidTest app
 */
val npmInstallTask = tasks.named<com.moowork.gradle.node.npm.NpmTask>("npm_install") {
    // make sure the build task is executed only when appropriate files change
    inputs.files(fileTree(rootProject.file("../../package.json")))
    setWorkingDir(rootProject.file("../.."))
    outputs.upToDateWhen { true }
}

tasks.whenTaskAdded {
    if (name.startsWith("assemble") && name.endsWith("AndroidTest")) {
        dependsOn(npmInstallTask)
    }
}
