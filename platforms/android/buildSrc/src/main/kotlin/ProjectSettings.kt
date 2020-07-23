//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

import org.gradle.api.Project

fun Project.getSettingValue(settingName: String) = findProperty(settingName) as String?

fun Project.includeTestCoverage() = project.hasProperty("includeCoverage")
