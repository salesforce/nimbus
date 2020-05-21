import org.gradle.api.Project
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.kotlin.dsl.withType

object Publishing {
    const val gitUrl = "https://github.com/salesforce/nimbus.git"
    const val siteUrl = "https://github.com/salesforce/nimbus"
    const val libraryDesc = "Bridge native code to web views in a consistent way on iOS and Android."
    const val licenseName = "BSD 3-clause"
    const val licenseUrl = "https://github.com/salesforce/nimbus/blob/master/LICENSE"
}

@Suppress("UnstableApiUsage")
fun MavenPublication.setupPom() = pom {
    name.set("nimbus")
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
            id.set("salesforce")
            name.set("Salesforce")
        }
    }
    scm {
        connection.set(Publishing.gitUrl)
        developerConnection.set(Publishing.gitUrl)
        url.set(Publishing.siteUrl)
    }
}

fun PublishingExtension.setupAllPublications(project: Project) {
    project.group = "com.salesforce.nimbus"
    project.version = ProjectVersions.thisLibrary
    val publications = publications.withType<MavenPublication>()
    publications.all { setupPom() }
}
