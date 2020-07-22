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
