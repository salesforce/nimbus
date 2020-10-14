//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//


import com.jfrog.bintray.gradle.BintrayExtension
import org.gradle.api.Project
import org.gradle.api.Task
import org.gradle.api.publish.PublishingExtension
import org.gradle.api.tasks.TaskProvider
import org.gradle.kotlin.dsl.closureOf
import org.gradle.kotlin.dsl.existing
import org.gradle.kotlin.dsl.getValue
import org.gradle.kotlin.dsl.provideDelegate
import com.android.build.gradle.internal.tasks.factory.dependsOn
import org.codehaus.groovy.runtime.ProcessGroovyMethods

fun BintrayExtension.setupPublicationsUpload(
    project: Project,
    publishing: PublishingExtension
) {
    val bintrayUpload: TaskProvider<Task> by project.tasks.existing
    val publishToMavenLocal: TaskProvider<Task> by project.tasks.existing

    bintrayUpload.dependsOn(publishToMavenLocal)

    if (!isSnapshot(project.version.toString())) {
        project.checkNoVersionRanges()
    }

//    bintrayUpload.configure {
//        doFirst {
//            val gitTag = ProcessGroovyMethods.getText(
//                Runtime.getRuntime().exec("git describe --dirty")
//            ).trim()
//            val expectedTag = "${project.version}"
//            if (gitTag != expectedTag) error("Expected git tag '$expectedTag' but got '$gitTag'")
//        }
//    }

    user = (project.getSettingValue("bintrayUser") ?: System.getenv("BINTRAY_USER"))
    key = (project.getSettingValue("bintrayApiKey") ?: System.getenv("BINTRAY_API_KEY"))
    val publicationNames: Array<String> = publishing.publications.map { it.name }.toTypedArray()
    setPublications(*publicationNames)
    pkg(closureOf<BintrayExtension.PackageConfig> {
        name = project.getSettingValue(PublishingSettingsKey.packageName)
        repo = project.getSettingValue(PublishingSettingsKey.bintrayRepo)
        userOrg = project.getSettingValue(PublishingSettingsKey.userOrg)
        setLicenses(project.getSettingValue(PublishingSettingsKey.licenseName))
        vcsUrl = project.getSettingValue(PublishingSettingsKey.gitUrl)
        websiteUrl = project.getSettingValue(PublishingSettingsKey.siteUrl)
        issueTrackerUrl = project.getSettingValue(PublishingSettingsKey.issuesUrl)
        publicDownloadNumbers = true
        githubRepo = project.getSettingValue(PublishingSettingsKey.githubRepo)
        publish = false
        dryRun = false
        version(closureOf<BintrayExtension.VersionConfig> {
            name = project.version.toString()
        })
    })
}

fun buildTagFor(version: String): String = if (isSnapshot(version)) "snapshot" else "release"

fun isSnapshot(version: String): Boolean = (version.substringAfterLast('-') == "SNAPSHOT")

