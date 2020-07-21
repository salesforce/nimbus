plugins {
    id("com.jfrog.artifactory") version "4.16.1"
}

val sourcesJar by tasks.creating(Jar::class) {
    dependsOn(JavaPlugin.CLASSES_TASK_NAME)
    classifier = "sources"
    from(sourceSets["main"].allSource)
}

task sourcesJar(type: Jar) {
    archiveClassifier.set("sources")
    from android.sourceSets.main.java.srcDirs
}

publishing {
    publications {
        create<MavenPublication>("mavenPublication") {
            artifact(sourcesJar)
        }
    }
}
