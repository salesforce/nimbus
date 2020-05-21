import groovy.json.JsonSlurper

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    id("jacoco-android")
}

android {
    setDefaults()
}

dependencies {
    api(project(":annotations"))
    api(project(":core"))
    kapt(project(":compiler-webview"))

    implementation(Libs.kotlin_stdlib)

    testImplementation(Libs.json)
    testImplementation(Libs.kotlintest_runner_junit4)
    testImplementation(Libs.mockk)
    kaptTest(project(":compiler-webview"))

    androidTestImplementation(Libs.kotlinx_serialization_runtime)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.androidx_test_rules) {
        exclude("com.android.support",  "support-annotations")
    }
    kaptAndroidTest(project(":compiler-webview"))
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}

apply(from= rootProject.file("gradle/lint.gradle"))
apply(from= rootProject.file("gradle/publishing.gradle"))
