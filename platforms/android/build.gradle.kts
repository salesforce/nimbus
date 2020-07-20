import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.dokka.gradle.DokkaTask
import org.gradle.api.GradleException

plugins {
    id("com.jfrog.artifactory")
    `maven-publish`
    id("org.jetbrains.dokka") version Versions.dokkaGradlePlugin
    id("org.jetbrains.kotlin.plugin.serialization") version "1.3.70"
    jacoco
}

allprojects {
    repositories {
        google()
        jcenter()
    }

    group = getSettingValue(PublishingSettingsKey.group) ?: ""
    val versionFile = file("$rootDir/../../lerna.json")
    val parsedFile = org.json.JSONObject(versionFile.readText())
    version = parsedFile.getString("version")
    tasks.withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}

jacoco {
    toolVersion = Versions.jacoco
//    setIgnoreProjects("demo-app", "shared-tests")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

tasks {
    val dokka by getting(DokkaTask::class) {
        outputFormat = "html"
        outputDirectory = "$buildDir/docs"
        subProjects = listOf("core", "core-plugins", "bridge-webview", "bridge-v8")
        configuration {
            moduleName = "nimbus"
        }
    }
}

tasks.register("publishSnapshot") {
    val publishTask = tasks.findByPath("artifactoryPublish")
    if (publishTask != null) {
        this.finalizedBy(publishTask)
    } else {
        throw GradleException("Unable to find the publish task")
    }
    doLast {
        val stringVersion = version.toString()
        val regex = "[0-9]+\\.[0-9]+\\.[0-9]+".toRegex()
        val numericVersion = regex.find(stringVersion)
        if (numericVersion != null) {
            version = numericVersion.value + "-SNAPSHOT"
        } else {
            logger.error("Version in project is invalid")
            throw GradleException("Version in project is invalid")
        }
    }
}

artifactory {
    setContextUrl("http://oss.jfrog.org")
    publish(delegateClosureOf<org.jfrog.gradle.plugin.artifactory.dsl.PublisherConfig> {
        repository(delegateClosureOf<groovy.lang.GroovyObject> {
            val targetRepoKey = "oss-${buildTagFor(project.version as String)}-local"
            setProperty("repoKey", targetRepoKey)
            setProperty("username", System.getenv("BINTRAY_USER"))
            setProperty("password", System.getenv("BINTRAY_API_KEY"))
            setProperty("maven", true)
        })
        defaults(delegateClosureOf<groovy.lang.GroovyObject> {
            invokeMethod("publications", "mavenPublication")
        })
    })
}

apply(from = rootProject.file("gradle/test-output.gradle.kts"))
