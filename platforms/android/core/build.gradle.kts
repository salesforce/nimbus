import groovy.json.JsonSlurper

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
}

android {
    setDefaults()
}

dependencies {
    implementation(project(":annotations"))
    implementation(Libs.kotlin_stdlib_jdk8)
    compileOnly(Libs.kotlinx_serialization_runtime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    testImplementation(Libs.kotlintest_runner_junit4)
    testImplementation(Libs.json)
}

//dokka {
//    outputFormat = "html"
//    outputDirectory = "$buildDir/dokka"
//}
//
apply(from= rootProject.file("gradle/lint.gradle"))
