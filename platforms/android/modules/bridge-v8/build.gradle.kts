import org.jetbrains.dokka.gradle.DokkaTask

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults(project)
}

dependencies {
    api(nimbusModule("core"))
    api(Libs.j2v8)
    api(Libs.kotlinStdlib)

    implementation(nimbusModule("annotations"))
    implementation(Libs.k2v8)
    implementation(Libs.kotlinxSerializationRuntime)

    kapt(nimbusModule("compiler-v8"))

    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.androidxTestRules) {
        exclude("com.android.support", "support-annotations")
    }
    androidTestImplementation(Libs.truth)
    androidTestImplementation(Libs.kotestRunnerJUnit5){
        exclude("io.mockk")
        exclude("io.github.classgraph")
    }
    androidTestImplementation(Libs.kotestProperty)

    kaptAndroidTest(nimbusModule("compiler-v8"))

    testImplementation(Libs.mockk)
    testImplementation(Libs.truth)

    kaptTest(nimbusModule("compiler-v8"))
}

addTestDependencies()

apply(from = rootProject.file("gradle/android-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
