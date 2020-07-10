import com.moowork.gradle.node.npm.NpmTask

plugins {
    id("com.android.library")
    kotlin("android")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.moowork.node") version "1.3.1"
}

android {
    setDefaults()
}
//fun String.runCommand(): String? {
//    try {
//        val parts = this.split("\\s".toRegex())
//        val proc = ProcessBuilder(*parts.toTypedArray())
//            .redirectOutput(ProcessBuilder.Redirect.PIPE)
//            .redirectError(ProcessBuilder.Redirect.PIPE)
//            .start()
//
//        proc.waitFor(1, TimeUnit.MINUTES)
//        return proc.inputStream.bufferedReader().readText().trim()
//    } catch (e: Exception) {
//        e.printStackTrace()
//        return null
//    }
//}
//
//gradle.afterProject {
//    if (name == "nimbusjs") {
//        println("Building nimbus.js")
//        "$rootDir/modules/nimbusjs/buildNimbusJS.sh".runCommand()
//    }
//}

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
    setWorkingDir("$rootDir/../../packages/nimbus-bridge")
}

tasks.named<NpmTask>("npm_build"){
    // make sure the build task is executed only when appropriate files change
    inputs.files(fileTree("$rootDir/../../packages/nimbus-bridge"))
    setWorkingDir("$rootDir/../../packages/nimbus-bridge")
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
