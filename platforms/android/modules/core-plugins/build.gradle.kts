plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    kotlin("kapt")
    id("org.jetbrains.dokka")
}

android {
    setDefaults(project)
}

dependencies {
    implementation(nimbusModule("core"))
    implementation(nimbusModule("annotations"))
    implementation(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
}

apply(from = rootProject.file("gradle/lint.gradle"))
