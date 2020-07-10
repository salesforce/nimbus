import com.moowork.gradle.node.npm.NpmTask

plugins {
    id("com.android.library")
    kotlin("android")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.github.node-gradle.node") version "2.2.4"
}

android {
    setDefaults()
}

dependencies {
    implementation(Libs.kotlinStdlib)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.truth)
}

addTestDependencies()

node {
    // try to use global instead of always downloading it
    download = false
}

tasks.named<NpmTask>("npm_install"){
    // make sure the build task is executed only when appropriate files change
    inputs.files(fileTree("$rootDir/../../packages/nimbus-bridge"))
    setWorkingDir(rootProject.file("../../packages/nimbus-bridge"))
}

tasks.named<NpmTask>("npm_build"){
    // make sure the build task is executed only when appropriate files change
    inputs.files(fileTree("$rootDir/../../packages/nimbus-bridge"))
    setWorkingDir(rootProject.file("../../packages/nimbus-bridge"))
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
