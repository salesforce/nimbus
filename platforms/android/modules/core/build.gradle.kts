plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
}

android {
    setDefaults()
}

dependencies {
    api(Libs.kotlin_stdlib)
    compileOnly(Libs.kotlinx_serialization_runtime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    testImplementation(Libs.junit)
    testImplementation(Libs.kotest_runner_junit5)
    testImplementation("io.kotest:kotest-property-jvm:${Versions.kotest_runner_junit5}")
    testImplementation("io.kotest:kotest-assertions-core-jvm:${Versions.kotest_runner_junit5}")
    testImplementation(Libs.json)
}

 apply(from= rootProject.file("gradle/android-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
//    artifactory {
//        setupSnapshots(project)
//    }
}


tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions.jvmTarget = "1.8"
}

apply(from = rootProject.file("gradle/lint.gradle"))
