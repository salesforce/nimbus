//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

plugins {
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
    api(nimbusModule("compiler-base"))
    implementation(nimbusModule("annotations"))
    api(Libs.kotlinpoet)
    api(Libs.kotlinxMetadataJvm)
}

apply(from = rootProject.file("gradle/java-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
