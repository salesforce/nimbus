plugins {
    `java-library`
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
}

//val publicationName = "com.salesforce.nimbus"
//val artifactID = "annotations"
//publishing {
//    publications.create<MavenPublication>(publicationName) {
//        from(components["java"])
//        artifactId = artifactID
//    }
//}
//
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
//apply(from= rootProject.file("gradle/publishing.gradle"))
