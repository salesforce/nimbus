plugins {
    `maven-publish`
    id("kotlin")
    id("com.jfrog.bintray")
}

dependencies {
    implementation(Libs.kotlinStdlib)
}

configure<JavaPluginExtension> {
    withSourcesJar()
    withJavadocJar()
}

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }
    bintray {
        setupPublicationsUpload(project, publishing)
    }
}
