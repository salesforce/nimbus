import org.gradle.api.Project
import org.gradle.api.artifacts.Dependency
import org.gradle.api.artifacts.dsl.DependencyHandler

fun DependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    // TODO: Verify configuration - without being set, artifactory doesn't match build versions.  Might need to set to release/debug though.
    return project(mapOf("path" to ":modules:$nimbusModule", "configuration" to "default"))
}

fun Project.isAndroidModule(): Boolean{
    return (project.plugins.hasPlugin("com.android.application") ||
        project.plugins.hasPlugin("com.android.library"))
}
