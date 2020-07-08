import org.gradle.api.Project

fun Project.getSettingValue(settingName: String) = findProperty(settingName) as String?
