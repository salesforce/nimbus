//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    `kotlin-dsl`
}
repositories {
    google()
    jcenter()
    mavenCentral()
    maven {
        url = uri("https://plugins.gradle.org/m2/")
    }
}

val kotlinVersion = "1.4.21" // Don't forget to update in Versions.kt too

dependencies {
    compileOnly(gradleApi())
    implementation("com.android.tools.build:gradle:4.1.0")
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    implementation("com.jfrog.bintray.gradle:gradle-bintray-plugin:1.8.5")
    implementation("org.jfrog.buildinfo:build-info-extractor-gradle:4.16.1")
}

configurations.all {
    // set jvmTarget for all kotlin projects
    tasks.withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}

kotlinDslPluginOptions {
    experimentalWarning.set(false)
}

allprojects {
    configurations.all {
        resolutionStrategy {
            force("org.objenesis:objenesis:2.6")
        }
    }
}
