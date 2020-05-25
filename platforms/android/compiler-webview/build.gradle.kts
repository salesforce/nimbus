plugins {
    `java-library`
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
    implementation(project(":compiler-base"))
    implementation(project(":annotations"))
    implementation(Libs.kotlinpoet)
    implementation(Libs.kotlinx_metadata_jvm)
}

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from=rootProject.file("gradle/lint.gradle"))
