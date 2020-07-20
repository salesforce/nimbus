plugins {
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
    implementation(nimbusModule("annotations"))
    api(Libs.kotlinpoet)
    api(Libs.kotlinxMetadataJvm)
    implementation(Libs.kotlinxSerializationRuntime)
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
