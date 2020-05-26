import org.gradle.api.Project
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.kotlin.dsl.create
import org.gradle.kotlin.dsl.get
import org.gradle.kotlin.dsl.withType

object Publishing {
    // TODO: Grab from config file?
    const val bintrayRepo = "jamiehouston-test"
    const val siteUrl = "https://github.com/salesforce/nimbus"
    const val userOrg = "jamie-houston"
    const val packageName = "jamie-nimbus"
    const val gitUrl = "$siteUrl.git"
    const val githubRepo = "salesforce/nimbus"
    const val libraryDesc = "Bridge native code to web views in a consistent way on iOS and Android."
    const val licenseName = "BSD 3-clause"
    const val licenseUrl = "$siteUrl/blob/master/LICENSE"
    const val issuesUrl = "$siteUrl/issues"
    const val developerName = "Salesforce inc."
    const val group = "com.salesforce.nimbus"
}

@Suppress("UnstableApiUsage")
fun MavenPublication.setupPom() = pom {
    // TODO: Should this be the same as artifactid?
    name.set(Publishing.packageName)
    description.set(Publishing.libraryDesc)
    url.set(Publishing.siteUrl)
    // TODO: Need to set packaging?  aar/jar?
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
//    val publicationName = "com.salesforce.nimbus"
//    val artifactID = "annotations"
//    publishing {
//        publications.create<MavenPublication>(publicationName) {
//            from(components["java"])
//            artifactId = artifactID
//        }
//    }
    val publication = publications.create<MavenPublication>(Publishing.group)
    println("components are ${project.components}")
    publication.from(project.components["java"])
    publication.artifactId = project.name

    project.group = Publishing.group
    project.version = ProjectVersions.packageVersion
    val publications = publications.withType<MavenPublication>()
    publications.all { setupPom() }
}
