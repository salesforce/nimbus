plugins {
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
}

apply(from = rootProject.file("gradle/java-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
