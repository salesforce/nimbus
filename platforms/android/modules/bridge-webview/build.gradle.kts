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
    id("com.jfrog.artifactory")
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
