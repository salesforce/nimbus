import com.android.build.gradle.internal.tasks.factory.dependsOn
import com.jfrog.bintray.gradle.BintrayExtension
import org.codehaus.groovy.runtime.ProcessGroovyMethods
import org.gradle.api.Project
import org.gradle.api.Task
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.tasks.TaskProvider
import org.gradle.kotlin.dsl.closureOf
import org.gradle.kotlin.dsl.existing
import org.gradle.kotlin.dsl.getValue
import org.gradle.kotlin.dsl.provideDelegate
import java.time.LocalDate

fun BintrayExtension.setupPublicationsUpload(
    project: Project,
    publishing: PublishingExtension,
    skipMetadataPublication: Boolean = false,
    skipMultiplatformPublication: Boolean = skipMetadataPublication
) {
    val bintrayUpload: TaskProvider<Task> by project.tasks.existing
    val publishToMavenLocal: TaskProvider<Task> by project.tasks.existing
    bintrayUpload.dependsOn(publishToMavenLocal)
    if (!isDevVersion) {
        project.checkNoVersionRanges()
        bintrayUpload.configure {
            doFirst {
                val gitTag = ProcessGroovyMethods.getText(
                    Runtime.getRuntime().exec("git describe --dirty")
                ).trim()
                val expectedTag = "v${ProjectVersions.thisLibrary}"
                if (gitTag != expectedTag) error("Expected git tag '$expectedTag' but got '$gitTag'")
            }
        }
    }
    user = (project.findProperty("bintrayUser") ?: System.getenv("BINTRAY_USER")) as String?
    key = (project.findProperty("bintrayApiKey") ?: System.getenv("BINTRAY_API_KEY")) as String?
    val publicationNames: Array<String> = publishing.publications.filterNot {
        skipMetadataPublication && it.name == "metadata" ||
            skipMultiplatformPublication && it.name == "kotlinMultiplatform"
    }.map { it.name }.toTypedArray()
    setPublications(*publicationNames)
    pkg(closureOf<BintrayExtension.PackageConfig> {
        repo = if (isDevVersion) "nimbus-dev" else "maven"
        name = "nimbus"
        desc = Publishing.libraryDesc
        websiteUrl = Publishing.siteUrl
        issueTrackerUrl = "https://github.com/salesforce/nimbus/issues"
        vcsUrl = Publishing.gitUrl
        setLicenses("BSD 3-clause")
        publicDownloadNumbers = true
        githubRepo = "salesforce/nimbus"
        publish = isDevVersion
        version(closureOf<BintrayExtension.VersionConfig> {
            name = ProjectVersions.parseVersion()
            released = LocalDate.now().toString()
        })
    })
}
