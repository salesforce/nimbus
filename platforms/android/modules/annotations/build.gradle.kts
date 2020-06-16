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
    implementation("org.jetbrains.kotlin:kotlin-reflect:1.3.72")
}

apply(from= rootProject.file("gradle/java-publishing-tasks.gradle"))

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

apply(from= rootProject.file("gradle/lint.gradle"))
