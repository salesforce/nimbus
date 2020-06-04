plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("android.extensions")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
}

android {
    setDefaults()
}
fun String.runCommand(): String? {
    try {
        val parts = this.split("\\s".toRegex())
        val proc = ProcessBuilder(*parts.toTypedArray())
            .redirectOutput(ProcessBuilder.Redirect.PIPE)
            .redirectError(ProcessBuilder.Redirect.PIPE)
            .start()

        proc.waitFor(1, TimeUnit.MINUTES)
        return proc.inputStream.bufferedReader().readText().trim()
    } catch (e: Exception) {
        e.printStackTrace()
        return null
    }
}

// TODO: Move this to before build... right now it's called whenever a sync or any task.
gradle.afterProject {
    if (name == "nimbusjs"){
        println("Building nimbus.js")
        "$rootDir/modules/nimbusjs/buildNimbusJS.sh".runCommand()
    }
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.kotlintest_runner_junit4)
    androidTestImplementation(Libs.truth)
}
apply(from= rootProject.file("gradle/publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
    artifactory {
        setupSnapshots(project)
    }
}

