plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults()
}

dependencies {
    api(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    testImplementation(Libs.junit)
    testImplementation(Libs.json)
    testImplementation(Libs.kotlinxSerializationRuntime)

}

addTestDependencies()

apply(from= rootProject.file("gradle/android-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
