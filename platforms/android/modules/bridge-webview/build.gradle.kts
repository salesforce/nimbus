plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    id("com.hiya.jacoco-android")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults()
}

dependencies {
    api(nimbusModule("annotations"))
    api(nimbusModule("core"))
    kapt(nimbusModule("compiler-webview"))

    implementation(Libs.kotlin_stdlib)

    testImplementation(Libs.json)
    testImplementation(Libs.kotlintest_runner_junit4)
    testImplementation(Libs.mockk)
    kaptTest(nimbusModule("compiler-webview"))

    androidTestImplementation(Libs.kotlinx_serialization_runtime)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.androidx_test_rules) {
        exclude("com.android.support",  "support-annotations")
    }
    kaptAndroidTest(nimbusModule("compiler-webview"))
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from= rootProject.file("gradle/lint.gradle"))
