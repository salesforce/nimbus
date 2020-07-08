plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
//    id("com.vanniktech.android.junit.jacoco")
    id("com.jfrog.bintray")
}

android {
    setDefaults()
}

dependencies {
    implementation(nimbusModule("annotations"))
    api(nimbusModule("core"))
    kapt(nimbusModule("compiler-webview"))

    api(Libs.kotlinStdlib)

    testImplementation(Libs.junit)
    testImplementation(Libs.json)
    testImplementation(Libs.mockk)
    androidTestImplementation(Libs.mockkAndroid)
    kaptTest(nimbusModule("compiler-webview"))

    kaptAndroidTest(nimbusModule("compiler-webview"))
}

addTestDependencies()

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}

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
