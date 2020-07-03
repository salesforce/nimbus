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
    compileOnly(nimbusModule("core"))
    compileOnly(nimbusModule("annotations"))
    compileOnly(nimbusModule("bridge-webview"))
    compileOnly(nimbusModule("bridge-v8"))
    api(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    kapt(nimbusModule("compiler-webview"))
    kapt(nimbusModule("compiler-v8"))
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}
apply(from = rootProject.file("gradle/lint.gradle"))
