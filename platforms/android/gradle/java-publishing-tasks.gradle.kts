plugins {
    id("com.jfrog.artifactory") version "4.16.1"
    java
    `maven-publish`
}

configure<JavaPluginExtension> {
    withSourcesJar()
    withJavadocJar()
}

//val artifactoryPublish: TaskProvider<ArtifactoryPublish> by project.tasks.existing
//artifactoryPublish.dependsOn("build")
//val publication = publications.create<MavenPublication>(Publishing.group)
//if (project.isAndroidModule()) {
//    publication.from(project.components["release"])
//} else {
//    publication.from(project.components["java"])
//}
//
//publications {
//    mavenPublication(MavenPublication) {
//        from(project.components["java"])
//    }
//}
publishing {
    publications {
        create<MavenPublication>("mavenPublication") {
            from(project.components["java"])
        }
    }
}
