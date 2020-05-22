import org.gradle.api.Action
import com.android.build.gradle.LibraryExtension as AndroidLibraryExtension

fun AndroidLibraryExtension.setDefaults() {
    compileSdkVersion(ProjectVersions.androidSdk)
    defaultConfig {
        minSdkVersion(ProjectVersions.minSdk)
        targetSdkVersion(ProjectVersions.androidSdk)
        versionCode = 1
        versionName = ProjectVersions.packageVersion
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            isTestCoverageEnabled = false
        }
        getByName("debug") {
            isTestCoverageEnabled = true
        }
    }

    // TODO: Set by project
    sourceSets.getByName("main") {
        res.srcDir("src/androidMain/res")
        assets.srcDir("src/main/assets")
    }

    testOptions {
        unitTests.apply {
            isReturnDefaultValues = true
        }
    }

    // TODO: Is this still necessary
    // TODO replace with https://issuetracker.google.com/issues/72050365 once released.
    libraryVariants.all(Action {
        generateBuildConfigProvider.configure {
            enabled = false
        }
    })
}
