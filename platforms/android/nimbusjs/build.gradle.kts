plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("android.extensions")
}

android {
    setDefaults()
}
fun String.runCommand(workingDir: File = file("./")): String? {
    try {
        val parts = this.split("\\s".toRegex())
        val proc = ProcessBuilder(*parts.toTypedArray())
            .directory(workingDir)
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

//defaultTasks("run")
tasks.register("run") {
//gradle.projectsEvaluated {
    doFirst {
        println("Building nimbus.js")
        "$rootDir/nimbusjs/buildNimbusJS.sh".runCommand()
//        val proc = "$rootDir/nimbusjs/buildNimbusJS.sh".execute()
//        proc.waitForProcessOutput(System.out, System.err)
    }
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espresso_core)
    androidTestImplementation(Libs.kotlintest_runner_junit4)
    androidTestImplementation(Libs.truth)
}
apply(from= rootProject.file("gradle/publishing.gradle"))
