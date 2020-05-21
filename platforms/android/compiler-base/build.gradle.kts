plugins {
    `java-library`
    id("kotlin")
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
    implementation(project(":annotations"))
    implementation(Libs.kotlinpoet)
    implementation(Libs.kotlinx_metadata_jvm)
    implementation(Libs.kotlinx_serialization_runtime)
}

apply(from= rootProject.file("gradle/lint.gradle"))
apply(from= rootProject.file("gradle/publishing.gradle"))
