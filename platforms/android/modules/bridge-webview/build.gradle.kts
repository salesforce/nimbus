plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults(project)
}

dependencies {
    implementation(nimbusModule("annotations"))
    api(nimbusModule("core"))
    kapt(nimbusModule("compiler-webview"))

    api(Libs.kotlinStdlib)

    testImplementation(Libs.junit)
    testImplementation(Libs.json)
    testImplementation(Libs.mockk)
    androidTestImplementation(Libs.mockkAndroid)
    kaptTest(nimbusModule("compiler-webview"))

    kaptAndroidTest(nimbusModule("compiler-webview"))
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
