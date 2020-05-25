plugins {
    `java-library`
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlin_stdlib_jdk8)
}

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from= rootProject.file("gradle/lint.gradle"))
