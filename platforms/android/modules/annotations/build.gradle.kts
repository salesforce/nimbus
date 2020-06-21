

plugins {
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")
}

dependencies {
    implementation(Libs.kotlin_stdlib)
}

//apply(from = rootProject.file("gradle/java-publishing-tasks.gradle"))
//
//afterEvaluate {
//    publishing {
//        setupAllPublications(project)
//    }
//    bintray {
//        setupPublicationsUpload(project, publishing)
//    }
//    artifactory {
//        setupSnapshots(project)
//    }
//}
//
apply(from = rootProject.file("gradle/lint.gradle"))
