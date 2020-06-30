plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
}

android {
    compileSdkVersion(29)

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
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
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

    implementation(Libs.kotlin_stdlib)
    implementation(Libs.kotlinx_serialization_runtime)
    implementation(Libs.j2v8)
    implementation(Libs.k2v8)
    implementation(Libs.appcompat)
}
