import org.gradle.api.artifacts.Dependency
import org.gradle.api.artifacts.dsl.DependencyHandler
import org.jetbrains.kotlin.gradle.plugin.KotlinDependencyHandler

fun DependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    return project(mapOf("path" to ":modules:$nimbusModule"))
}

fun KotlinDependencyHandler.nimbusModule(nimbusModule: String): Dependency {
    return project(mapOf("path" to ":modules:$nimbusModule"))
}
