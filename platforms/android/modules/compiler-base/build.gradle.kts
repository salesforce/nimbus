plugins {
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
}

dependencies {
    implementation(Libs.kotlin_stdlib)
    implementation(nimbusModule("annotations"))
    api(Libs.kotlinpoet)
    api(Libs.kotlinx_metadata_jvm)
    implementation(Libs.kotlinx_serialization_runtime)
}

apply(from = rootProject.file("gradle/java-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
    artifactory {
        setupSnapshots(project)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
