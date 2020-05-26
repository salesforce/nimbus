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
    publishing: PublishingExtension
) {
    val bintrayUpload: TaskProvider<Task> by project.tasks.existing
    val publishToMavenLocal: TaskProvider<Task> by project.tasks.existing

    bintrayUpload.dependsOn(publishToMavenLocal)

    // TODO: Is this necessary?
//    project.checkNoVersionRanges()

    // TODO: Add this back... I like it
//    bintrayUpload.configure {
//        doFirst {
//            val gitTag = ProcessGroovyMethods.getText(
//                Runtime.getRuntime().exec("git describe --dirty")
//            ).trim()
//            val expectedTag = "v${ProjectVersions.packageVersion}"
//            if (gitTag != expectedTag) error("Expected git tag '$expectedTag' but got '$gitTag'")
//        }
//    }

    user = (project.findProperty("bintrayUser") ?: System.getenv("BINTRAY_USER")) as String?
    key = (project.findProperty("bintrayApiKey") ?: System.getenv("BINTRAY_API_KEY")) as String?
    val publicationNames: Array<String> = publishing.publications.map { it.name }.toTypedArray()
    setPublications(*publicationNames)
    pkg(closureOf<BintrayExtension.PackageConfig> {
        name = Publishing.packageName
        repo = Publishing.bintrayRepo
        userOrg = Publishing.userOrg
        setLicenses(Publishing.licenseName)
        desc = Publishing.libraryDesc
        vcsUrl = Publishing.gitUrl
        websiteUrl = Publishing.siteUrl
        issueTrackerUrl = Publishing.issuesUrl
        publicDownloadNumbers = true
        githubRepo = Publishing.githubRepo
        publish = true
        dryRun = true
        version(closureOf<BintrayExtension.VersionConfig> {
            name = ProjectVersions.packageVersion
        })
    })
}
