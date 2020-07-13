plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
}

android {
    setDefaults(project)
    defaultConfig {
        applicationId = "com.salesforce.nimbusdemoapp"
    }
    buildTypes.all {
        isTestCoverageEnabled = false
    }
}

dependencies {
    implementation(nimbusModule("bridge-webview"))
    implementation(nimbusModule("bridge-v8"))
    implementation(nimbusModule("core-plugins"))
    implementation(nimbusModule("core"))
    implementation(nimbusModule("annotations"))
    kapt(nimbusModule("compiler-webview"))
    kapt(nimbusModule("compiler-v8"))

    implementation(Libs.appcompat)
    implementation(Libs.constraintLayout)
    implementation(Libs.j2v8)
    implementation(Libs.k2v8)
    implementation(Libs.kotlinStdlib)
    implementation(Libs.kotlinxSerializationRuntime)
}
