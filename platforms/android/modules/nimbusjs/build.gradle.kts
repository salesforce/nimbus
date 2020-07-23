//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import com.moowork.gradle.node.npm.NpmTask

plugins {
    id("com.android.library")
    kotlin("android")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.github.node-gradle.node") version "2.2.4"
}

android {
    setDefaults(project)
}

dependencies {
    implementation(Libs.kotlinStdlib)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.truth)
}

addTestDependencies()

node {
    // try to use global instead of always downloading it
    download = false
}

val copyScript by tasks.registering(Copy::class) {
    dependsOn(npmInstallTask)
    from(rootProject.file("../../packages/nimbus-bridge/dist/iife/nimbus.js"))
    into(file("src/main/assets/"))
}

val npmInstallTask = tasks.named<NpmTask>("npm_install") {
    // make sure the build task is executed only when appropriate files change
    inputs.files(fileTree("$rootDir/../../packages/nimbus-bridge"))
    setWorkingDir(rootProject.file("../../packages/nimbus-bridge"))
    outputs.upToDateWhen { true }
}

tasks.whenTaskAdded {
    if (name.startsWith("assemble")) {
        dependsOn(copyScript)
    }
}

val sourcesJar by tasks.creating(Jar::class) {
    archiveClassifier.set("sources")
    from(android.sourceSets.getByName("main").java.srcDirs)
}
afterEvaluate {
    publishing {
        setupAllPublications(project)
        publications.getByName<MavenPublication>("mavenPublication") {
            artifact(sourcesJar)
        }
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}
