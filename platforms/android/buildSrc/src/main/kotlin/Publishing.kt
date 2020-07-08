import org.gradle.api.Project
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.publish.maven.MavenPublication
import org.gradle.kotlin.dsl.get
import org.gradle.kotlin.dsl.withType

object PublishingSettingsKey {
    const val bintrayRepo = "BINTRAY_REPO"
    const val siteUrl = "POM_SCM_URL"
    const val userOrg = "BINTRAY_ORG"
    const val packageName = "PACKAGE_NAME"
    const val gitUrl = "POM_SCM_CONNECTION"
    const val githubRepo = "POM_GITHUB_REPO"
    const val licenseName = "POM_LICENSE_NAME"
    const val licenseUrl = "POM_LICENSE_URL"
    const val issuesUrl = "POM_ISSUE_URL"
    const val developerName = "POM_DEVELOPER"
    const val group = "GROUP"
}

@Suppress("UnstableApiUsage")
fun MavenPublication.setupPom(project: Project) = pom {
    name.set(project.getSettingValue(PublishingSettingsKey.packageName))
    url.set(project.getSettingValue(PublishingSettingsKey.siteUrl))
    licenses {
        license {
            name.set(project.getSettingValue(PublishingSettingsKey.licenseName))
            url.set(project.getSettingValue(PublishingSettingsKey.licenseUrl))
        }
    }
    developers {
        developer {
            name.set(project.getSettingValue(PublishingSettingsKey.developerName))
        }
    }
    scm {
        connection.set(project.getSettingValue(PublishingSettingsKey.gitUrl))
        developerConnection.set(project.getSettingValue(PublishingSettingsKey.gitUrl))
        url.set(project.getSettingValue(PublishingSettingsKey.siteUrl))
    }
}

fun PublishingExtension.setupAllPublications(project: Project) {
    val publication = publications.getByName("mavenPublication") as MavenPublication

    publication.artifactId = project.name

    val publications = publications.withType<MavenPublication>()
    publications.all { setupPom(project) }
}
