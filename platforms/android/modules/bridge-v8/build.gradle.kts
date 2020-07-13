import org.jetbrains.dokka.gradle.DokkaTask

plugins {
    id("com.android.library")
    kotlin("android")
    kotlin("kapt")
    kotlin("plugin.serialization")
    id("org.jetbrains.dokka")
    `maven-publish`
    id("com.jfrog.bintray")
}

android {
    setDefaults(project)
    packagingOptions {
        excludes.add("META-INF/LICENSE.md")
        excludes.add("META-INF/LICENSE-notice.md")
        excludes.add("META-INF/DEPENDENCIES")
        excludes.add("META-INF/LICENSE")
        excludes.add("META-INF/LICENSE.txt")
        excludes.add("META-INF/license.txt")
        excludes.add("META-INF/NOTICE")
        excludes.add("META-INF/NOTICE.txt")
        excludes.add("META-INF/notice.txt")
        excludes.add("META-INF/ASL2.0")
        excludes.add("META-INF/*.kotlin_module")
    }
}

dependencies {
    implementation(nimbusModule("annotations"))
    api(nimbusModule("core"))
    implementation(Libs.k2v8)
    kapt(nimbusModule("compiler-v8"))

    api(Libs.j2v8)
    implementation(Libs.kotlinxSerializationRuntime)
    api(Libs.kotlinStdlib)

    androidTestImplementation(Libs.mockkAndroid)
    androidTestImplementation(Libs.junit)
    androidTestImplementation(Libs.espressoCore)
    androidTestImplementation(Libs.androidxTestRules) {
        exclude("com.android.support", "support-annotations")
    }
    androidTestImplementation(Libs.truth)
    androidTestImplementation(Libs.kotestProperty)
    androidTestImplementation(Libs.mockkAndroid)
    kaptAndroidTest(nimbusModule("compiler-v8"))

    testImplementation(Libs.mockk)
    testImplementation(Libs.truth)
    kaptTest(nimbusModule("compiler-v8"))
}

addTestDependencies()

apply(from = rootProject.file("gradle/android-publishing-tasks.gradle"))

afterEvaluate {
    publishing {
        setupAllPublications(project)
    }

    bintray {
        setupPublicationsUpload(project, publishing)
    }
}

apply(from = rootProject.file("gradle/lint.gradle"))
