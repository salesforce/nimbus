import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    `kotlin-dsl`
}
repositories {
    google()
    jcenter()
    mavenCentral()
}

val kotlinVersion = "1.3.72" // Don't forget to update in Versions.kt too

dependencies {
    compileOnly(gradleApi())
    implementation("com.android.tools.build:gradle:4.0.0")
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    implementation("com.jfrog.bintray.gradle:gradle-bintray-plugin:1.8.5")
    implementation("org.jfrog.buildinfo:build-info-extractor-gradle:4.16.0")
}

configurations.all {
    // set jvmTarget for all kotlin projects
    tasks.withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
    tasks.withType<Test> {
        useJUnitPlatform()
    }
}

kotlinDslPluginOptions {
    experimentalWarning.set(false)
}
