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
//j       if (project.isandroidmodule()){
//            add("androidtestimplementation", "io.kotest:kotest-$it-jvm:${versions.kotest}")
//        }
    }
}
