plugins {
    id("kotlin")
    `maven-publish`
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
}

dependencies {
    implementation(Libs.kotlinStdlib)
    api(nimbusModule("compiler-base"))
    implementation(nimbusModule("annotations"))
    api(Libs.kotlinpoet)
    api(Libs.kotlinxMetadataJvm)
}

apply(from = rootProject.file("gradle/java-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
//    artifactory {
//        setupSnapshots(project)
//    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
