import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    `kotlin-dsl`
}
repositories {
    google()
    jcenter()
    mavenCentral()
}

val kotlinVersion = "1.3.72" // Don't forget to update in Dependencies.kt too!

dependencies {
    compileOnly(gradleApi())
    implementation("com.android.tools.build:gradle:3.6.3")
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    implementation("com.jfrog.bintray.gradle:gradle-bintray-plugin:1.8.5")
    implementation("org.jfrog.buildinfo:build-info-extractor-gradle:latest.release")
}

configurations.all {
    val isKotlinCompiler = name == "embeddedKotlin" ||
        name.startsWith("kotlin") ||
        name.startsWith("kapt")
    if (!isKotlinCompiler) {
        resolutionStrategy.eachDependency {
            @Suppress("UnstableApiUsage")
            if (requested.group == "org.jetbrains.kotlin" &&
                requested.module.name == "kotlin-compiler-embeddable"
            ) useVersion(kotlinVersion)
        }
    }
    // set jvmTarget for all kotlin projects
    tasks.withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}
