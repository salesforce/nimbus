plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
}

android {
    compileSdkVersion(ProjectVersions.androidSdk)

    defaultConfig {
        applicationId = "com.salesforce.nimbusdemoapp"
        minSdkVersion(ProjectVersions.minSdk)
        targetSdkVersion(ProjectVersions.androidSdk)
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
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

    implementation(Libs.kotlinStdlib)
    implementation(Libs.kotlinxSerializationRuntime)
    implementation(Libs.j2v8)
    implementation(Libs.k2v8)
    implementation(Libs.appcompat)
}
