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
    implementation(nimbusModule("core"))
    implementation(nimbusModule("annotations"))
    implementation(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}
apply(from = rootProject.file("gradle/lint.gradle"))
