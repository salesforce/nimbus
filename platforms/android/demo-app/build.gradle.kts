plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("android.extensions")
    kotlin("kapt")
    kotlin("plugin.serialization")
}

android {
    compileSdkVersion(29)

    defaultConfig {
        applicationId = "com.salesforce.nimbusdemoapp"
        minSdkVersion(21)
        targetSdkVersion(29)
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
}

dependencies {
    implementation(project(":bridge-webview"))
    implementation(project(":bridge-v8"))
    implementation(project(":core-plugins"))
    kapt(project(":compiler-webview"))
    kapt(project(":compiler-v8"))

    implementation(Libs.kotlin_stdlib_jdk8)
    implementation(Libs.kotlinx_serialization_runtime)
    implementation(Libs.j2v8)
    implementation(Libs.appcompat)
    implementation(Libs.constraintlayout)
}
