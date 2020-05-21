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
    api(Libs.k2v8)
    kapt(project(":compiler-v8"))

    implementation(Libs.j2v8)
    implementation(Libs.kotlinx_serialization_runtime)
    implementation(Libs.kotlin_stdlib_jdk8)

    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.androidx_test_rules){
        exclude ("com.android.support", "support-annotations")
    }
    androidTestImplementation(Libs.truth)
    androidTestImplementation(Libs.kotlintest_runner_junit4)
    kaptAndroidTest(project(":compiler-v8"))

    testImplementation(Libs.mockk)
    testImplementation(Libs.truth)
    kaptTest(project(":compiler-v8"))
}


//dokka {
//    outputFormat = "html"
//    outputDirectory = "$buildDir/dokka"
//}

apply(from= rootProject.file("gradle/lint.gradle"))
apply(from= rootProject.file("gradle/publishing.gradle"))
