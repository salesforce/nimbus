import com.android.build.gradle.internal.tasks.factory.dependsOn
import com.jfrog.bintray.gradle.BintrayExtension
import org.codehaus.groovy.runtime.ProcessGroovyMethods
import org.gradle.api.Project
import org.gradle.api.Task
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.tasks.TaskProvider
import org.gradle.kotlin.dsl.closureOf
import org.gradle.kotlin.dsl.delegateClosureOf
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
    publicationNames.forEach { println("Publication: $it") }
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
            name = project.version.toString()
        })
    })
}

fun org.jfrog.gradle.plugin.artifactory.dsl.ArtifactoryPluginConvention.setupSnapshots(project: Project){
    setContextUrl("http://oss.jfrog.org")
    publish(delegateClosureOf<org.jfrog.gradle.plugin.artifactory.dsl.PublisherConfig> {
        repository(delegateClosureOf<groovy.lang.GroovyObject> {
            val targetRepoKey = "oss-${buildTagFor(project.version as String)}-local"
            println("publishing version ${project.version}")
            println("publishing to $targetRepoKey")
            setProperty("repoKey", targetRepoKey)
            setProperty("username", project.findProperty("bintrayUser") ?: System.getenv("BINTRAY_USER"))
            setProperty("password", project.findProperty("bintrayApiKey") ?: System.getenv("BINTRAY_API_KEY"))
            setProperty("maven", true)
        })
        defaults(delegateClosureOf<groovy.lang.GroovyObject> {
//            invokeMethod("publications", "com.salesforce.nimbus")
            invokeMethod("publications", getPublications(project))
//            invokeMethod("publishConfigs", arrayOf("archives"))
            setProperty("publishArtifacts", true)
            setProperty("publishPom", true)
            setProperty("publishIvy", false)
        })
    })
    resolve(delegateClosureOf<org.jfrog.gradle.plugin.artifactory.dsl.ResolverConfig> {
        setProperty("repoKey", "jcenter")
        setProperty("maven", true)
    })
//    clientConfig.info.buildNumber = ProjectVersions.packageVersion
}

fun buildTagFor(version: String): String =
    when (version.substringAfterLast('-')) {
        "SNAPSHOT" -> "snapshot"
        else -> "release"
    }
fun getPublications(project: Project): Array<String> {
//    return if (project.isAndroidModule()) {
//        arrayOf("androidDebug", "androidRelease")
 return       arrayOf("mavenPublication")
//    } else {
//        arrayOf("mavenJava")
//        arrayOf("java")
//    }
}
