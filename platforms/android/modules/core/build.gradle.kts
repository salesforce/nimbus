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
    testImplementation(Libs.kotlintest_runner_junit4)
    testImplementation(Libs.json)
}

 apply(from= rootProject.file("gradle/android-publishing-tasks.gradle"))

    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
//    artifactory {
//        setupSnapshots(project)
//    }


tasks {
    val dokka by getting(org.jetbrains.dokka.gradle.DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/dokka"
    }
}
apply(from = rootProject.file("gradle/lint.gradle"))
