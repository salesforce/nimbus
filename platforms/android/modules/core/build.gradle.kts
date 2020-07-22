plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults(project)
}

dependencies {
    api(Libs.kotlinStdlib)
    compileOnly(Libs.kotlinxSerializationRuntime)
    compileOnly(Libs.j2v8)
    compileOnly(Libs.k2v8)
    testImplementation(Libs.junit)
    testImplementation(Libs.json)
    testImplementation(Libs.kotlinxSerializationRuntime)
}

addTestDependencies()

val sourcesJar by tasks.creating(Jar::class) {
    archiveClassifier.set("sources")
    from(android.sourceSets.getByName("main").java.srcDirs)
}
afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("mavenPublication") {
                artifact(sourcesJar)
            }
        }
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}
