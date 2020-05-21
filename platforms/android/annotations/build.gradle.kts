plugins {
    `java-library`
    id("kotlin")
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
}

apply(from= rootProject.file("gradle/lint.gradle"))
apply(from= rootProject.file("gradle/publishing.gradle"))
