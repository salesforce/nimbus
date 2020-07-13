import org.gradle.api.Project

fun Project.getSettingValue(settingName: String) = findProperty(settingName) as String?

fun Project.includeTestCoverage() = project.hasProperty("includeCoverage")
