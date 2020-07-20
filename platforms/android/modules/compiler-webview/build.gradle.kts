plugins {
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
    api(nimbusModule("compiler-base"))
    implementation(nimbusModule("annotations"))
    api(Libs.kotlinpoet)
    api(Libs.kotlinxMetadataJvm)
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
