plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("android.extensions")
}

android {
    setDefaults()
}
fun String.runCommand(): String? {
    try {
        val parts = this.split("\\s".toRegex())
        println("building ${parts[0]}")
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

gradle.afterProject {
    if (name == "nimbusjs"){
        println("Building nimbus.js")
        "$rootDir/nimbusjs/buildNimbusJS.sh".runCommand()
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
