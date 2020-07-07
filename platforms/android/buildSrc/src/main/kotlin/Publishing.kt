import org.gradle.api.Project
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.kotlin.dsl.get
import org.gradle.kotlin.dsl.withType

object Publishing {
    // TODO: Grab from config file?
    const val bintrayRepo = "android"
    const val siteUrl = "https://github.com/salesforce/nimbus"
    const val userOrg = "salesforce-mobile"
    const val packageName = "nimbus"
    const val gitUrl = "$siteUrl.git"
    const val githubRepo = "salesforce/nimbus"
    const val libraryDesc = "Bridge native code to web views in a consistent way on iOS and Android."
    const val licenseName = "BSD 3-clause"
    const val licenseUrl = "$siteUrl/blob/master/LICENSE"
    const val issuesUrl = "$siteUrl/issues"
    const val developerName = "Salesforce inc."
}

@Suppress("UnstableApiUsage")
fun MavenPublication.setupPom() = pom {
    name.set(Publishing.packageName)
    description.set(Publishing.libraryDesc)
    url.set(Publishing.siteUrl)
    licenses {
        license {
            name.set(Publishing.licenseName)
            url.set(Publishing.licenseUrl)
        }
    }
    developers {
        developer {
            name.set(Publishing.developerName)
        }
    }
    scm {
        connection.set(Publishing.gitUrl)
        developerConnection.set(Publishing.gitUrl)
        url.set(Publishing.siteUrl)
    }
}

fun PublishingExtension.setupAllPublications(project: Project) {
    val publication = publications.getByName("mavenPublication") as MavenPublication

    if (!project.isAndroidModule()) {

//    val publication = publications.create<MavenPublication>("mavenLocal")
// //        artifact(LazyPublishArtifact(sourcesJar))
// //    }
//    println("publication is ${publication.name}")
//    if (project.isAndroidModule()) {
//        publication.from(project.components["release"])
//    } else {
        publication.from(project.components["java"])
    }

    publication.artifactId = project.name

    val publications = publications.withType<MavenPublication>()
    publications.all { setupPom() }
}
