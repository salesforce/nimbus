//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import org.gradle.api.Project

fun Project.checkNoVersionRanges() {
    configurations.forEach {
        it.resolutionStrategy {
            eachDependency {
                val version = requested.version ?: return@eachDependency
                check('+' !in version) {
                    "Version ranges are forbidden because they would make builds non reproducible."
                }
                check("SNAPSHOT" !in version) {
                    println("${project.name} using ${requested.name} has ${requested.version}")
                    "Snapshot versions are forbidden because they would make builds non reproducible."
                }
            }
        }
    }
}
