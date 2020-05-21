plugins {
    `java-library`
    id("kotlin")
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
    implementation(project(":compiler-base"))
    implementation(project(":annotations"))
    implementation(Libs.kotlinpoet)
    implementation(Libs.kotlinx_metadata_jvm)
}
apply(from=rootProject.file("gradle/lint.gradle"))
apply(from= rootProject.file("gradle/publishing.gradle"))
