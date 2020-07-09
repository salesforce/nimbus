plugins {
    id("com.android.library")
    id("kotlin-android")
    id("kotlin-kapt")
    id("kotlinx-serialization")
}

android {
    setDefaults()

    sourceSets.getByName("androidTest") {
        assets.srcDirs("../../../packages/test-www/dist", "../../../packages/nimbus-bridge/dist/iife")
    }

    packagingOptions {
        pickFirst("META-INF/LICENSE*")
        pickFirst("META-INF/DEPENDENCIES")
    }
}

dependencies {
    androidTestImplementation(nimbusModule("annotations"))
    androidTestImplementation(nimbusModule("bridge-v8"))
    androidTestImplementation(nimbusModule("bridge-webview"))
    androidTestImplementation(nimbusModule("core"))
    kaptAndroidTest(nimbusModule("compiler-webview"))
    kaptAndroidTest(nimbusModule("compiler-v8"))
    androidTestImplementation(Libs.androidxTestRules) {
        exclude("com.android.support", "support-annotations")
    }
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.guava)
    androidTestImplementation(Libs.j2v8)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.k2v8)
    androidTestImplementation(Libs.kotlinxSerializationRuntime)
    androidTestImplementation(Libs.truth)
}

/*
 * Compile the test web app prior to assembling the androidTest app
 */
val buildTestWebApp = tasks.register<Exec>("buildTestWebApp") {
    workingDir = File("$rootProject/../../..")
    commandLine = "npm install".split(" ")
}

tasks.withType<Assemble>().configureEach {
    dependsOn(buildTestWebApp)
}

apply(from = rootProject.file("gradle/lint.gradle"))
