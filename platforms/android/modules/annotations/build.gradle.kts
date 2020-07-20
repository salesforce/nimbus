plugins {
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
}

afterEvaluate {
    publishing {
        apply(from = rootProject.file("gradle/java-publishing-tasks.gradle.kts"))
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
}
