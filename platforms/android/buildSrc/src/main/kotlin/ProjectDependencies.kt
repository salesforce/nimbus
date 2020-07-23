//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import org.gradle.api.Project
import org.gradle.api.artifacts.Dependency
import org.gradle.api.artifacts.dsl.DependencyHandler
import org.gradle.kotlin.dsl.dependencies

fun DependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    return project(mapOf("path" to ":modules:$nimbusModule"))
}

fun Project.isAndroidModule(): Boolean {
    return (project.plugins.hasPlugin("com.android.application") ||
        project.plugins.hasPlugin("com.android.library"))
}

fun Project.addTestDependencies() = dependencies {
    listOf("runner-junit5", "assertions-core", "runner-console", "property").forEach {
        add("testImplementation", "io.kotest:kotest-$it-jvm:${Versions.kotest}")
    }
}
