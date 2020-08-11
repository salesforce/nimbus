//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

plugins {
    id("com.android.library")
    kotlin("android")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
    id("com.github.node-gradle.node") version Versions.nodeGradle
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
