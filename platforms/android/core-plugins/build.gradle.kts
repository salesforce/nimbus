plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    kotlin("kapt")
    id("org.jetbrains.dokka")
}

android {
    setDefaults()
}

dependencies {
    compileOnly(project(":core"))
    compileOnly(project(":annotations"))
    compileOnly(project(":bridge-webview"))
    compileOnly(project(":bridge-v8"))
    implementation(Libs.kotlin_stdlib_jdk8)
    compileOnly(Libs.kotlinx_serialization_runtime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    kapt(project(":compiler-webview"))
    kapt(project(":compiler-v8"))
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}
apply(from= rootProject.file("gradle/lint.gradle"))
