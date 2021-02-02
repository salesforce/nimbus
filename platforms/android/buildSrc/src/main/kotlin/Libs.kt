//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import kotlin.String

object Libs {
    const val kotlinxSerializationRuntime: String =
            "org.jetbrains.kotlinx:kotlinx-serialization-json:" +
            Versions.kotlinxSerialization

    const val kotlinGradlePlugin: String = "org.jetbrains.kotlin:kotlin-gradle-plugin:" +
            Versions.kotlin

    const val kotlinSerialization: String = "org.jetbrains.kotlin:kotlin-serialization:" +
            Versions.kotlin

    const val kotlinStdlib: String = "org.jetbrains.kotlin:kotlin-stdlib:" +
            Versions.kotlin

    const val kotestAssertions: String = "io.kotest:kotest-assertions-core-jvm:" +
            Versions.kotest

    const val kotestProperty: String = "io.kotest:kotest-property:" + Versions.kotest

    const val kotestRunnerJUnit5: String = "io.kotest:kotest-runner-junit5:" +
            Versions.kotest

    const val kotestRunnerConsole: String = "io.kotest:kotest-runner-console:" +
        Versions.kotest

    const val mockk: String = "io.mockk:mockk:" + Versions.mockk

    const val mockkAndroid: String = "io.mockk:mockk-android:" + Versions.mockk

    const val androidToolsBuildGradle: String = "com.android.tools.build:gradle:" +
            Versions.androidToolsBuildGradle

    const val androidxTestRules: String = "androidx.test:rules:" + Versions.androidxTestRules

    const val buildInfoExtractorGradle: String =
            "org.jfrog.buildinfo:build-info-extractor-gradle:" +
            Versions.buildInfoExtractorGradle

    const val gradleBintrayPlugin: String = "com.jfrog.bintray.gradle:gradle-bintray-plugin:" +
            Versions.gradle_bintray_plugin

    const val kotlinxMetadataJvm: String = "org.jetbrains.kotlinx:kotlinx-metadata-jvm:" +
            Versions.kotlinxMetadataJvm

    const val dokkaGradlePlugin: String = "org.jetbrains.dokka:dokka-gradle-plugin:" +
            Versions.dokkaGradlePlugin

    const val espressoCore: String = "androidx.test.espresso:espresso-core:" +
            Versions.espressoCore

    const val kotlinpoet: String = "com.squareup:kotlinpoet:" + Versions.kotlinpoet

    const val appcompat: String = "androidx.appcompat:appcompat:" + Versions.appcompat

    const val constraintLayout: String = "androidx.constraintlayout:constraintlayout:" + Versions.constraintLayout

    const val guava: String = "com.google.guava:guava:" + Versions.guava

    const val junit: String = "androidx.test.ext:junit:" + Versions.junit

    const val truth: String = "com.google.truth:truth:" + Versions.truth

    const val j2v8: String = "com.eclipsesource.j2v8:j2v8:" + Versions.j2v8

    const val json: String = "org.json:json:" + Versions.json

    const val k2v8: String = "com.salesforce.k2v8:k2v8:" + Versions.k2v8
}
