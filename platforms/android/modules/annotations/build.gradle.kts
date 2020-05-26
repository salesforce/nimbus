import com.android.build.gradle.internal.scope.publishArtifactToConfiguration

plugins {
    `java-library`
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
    id("com.jfrog.artifactory")

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
    artifactory {
        setupSnapshots()
    }
}


apply(from= rootProject.file("gradle/lint.gradle"))
//apply(from= rootProject.file("gradle/publishing.gradle"))
