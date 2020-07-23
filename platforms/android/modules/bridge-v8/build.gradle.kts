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
    api(nimbusModule("core"))
    api(Libs.j2v8)
    api(Libs.kotlinStdlib)

    implementation(nimbusModule("annotations"))
    implementation(Libs.k2v8)
    implementation(Libs.kotlinxSerializationRuntime)

    kapt(nimbusModule("compiler-v8"))

    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.truth)

    androidTestImplementation(Libs.kotestProperty)
    androidTestImplementation(Libs.kotestAssertions)
    androidTestImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.3.7")

    kaptAndroidTest(nimbusModule("compiler-v8"))

    testImplementation(Libs.mockk)
    testImplementation(Libs.truth)

    kaptTest(nimbusModule("compiler-v8"))
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
