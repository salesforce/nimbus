import groovy.json.JsonSlurper

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
}
android {
    setDefaults()

    sourceSets.getByName("androidTest") {
        assets.srcDirs("../../../packages/test-www/dist", "../../../packages/nimbus-bridge/dist/iife")
    }
}

dependencies {
    androidTestImplementation(project(":annotations"))
    androidTestImplementation(Libs.k2v8)
    androidTestImplementation(project(":bridge-v8"))
    androidTestImplementation(project(":bridge-webview"))
    androidTestImplementation(Libs.j2v8)
    androidTestImplementation(Libs.guava)
    kaptAndroidTest(project(":compiler-webview"))
    kaptAndroidTest(project(":compiler-v8"))

    androidTestImplementation(Libs.kotlinx_serialization_runtime)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.androidx_test_rules) {
        exclude("com.android.support","support-annotations")
    }
    androidTestImplementation(Libs.truth)
    androidTestImplementation(Libs.kotlintest_runner_junit4)
}

/*
 * Compile the test web app prior to assembling the androidTest app
 */
tasks.register<Exec>("buildTestWebApp") {
    workingDir = File("../../..")
    commandLine("npm", "install")
}

// TODO: Rewire this or convert back to build.gradle
//tasks.whenTaskAdded { task ->
//    if (task.name == "assemble.*AndroidTest") {
//        task.dependsOn(buildTestWebApp)
//    }
//}

apply(from= rootProject.file("gradle/lint.gradle"))
