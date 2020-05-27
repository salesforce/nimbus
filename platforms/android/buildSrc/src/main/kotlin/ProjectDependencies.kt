import org.gradle.api.Project
import org.gradle.api.artifacts.Dependency
import org.gradle.api.artifacts.dsl.DependencyHandler
import org.jetbrains.kotlin.gradle.plugin.KotlinDependencyHandler

fun DependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    return project(mapOf("path" to ":modules:$nimbusModule", "configuration" to "default"))
}

fun KotlinDependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    return project(mapOf("path" to ":modules:$nimbusModule", "configuration" to "default"))
}

fun Project.isAndroidModule(): Boolean{
    return (project.plugins.hasPlugin("com.android.application") ||
        project.plugins.hasPlugin("com.android.library"))
}
