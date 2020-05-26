import org.jetbrains.dokka.gradle.DokkaTask

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
//    id("jacoco-android")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults()
}

dependencies {
    api(nimbusModule("annotations"))
    api(nimbusModule("core"))
    api(Libs.k2v8)
    kapt(nimbusModule("compiler-v8"))

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
    kaptAndroidTest(nimbusModule("compiler-v8"))

    testImplementation(Libs.mockk)
    testImplementation(Libs.truth)
    kaptTest(nimbusModule("compiler-v8"))
}

tasks {
    val dokka by getting(DokkaTask::class) {
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
