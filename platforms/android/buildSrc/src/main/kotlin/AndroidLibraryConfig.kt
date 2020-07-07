import org.gradle.api.JavaVersion
import com.android.build.gradle.LibraryExtension as AndroidLibraryExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

fun AndroidLibraryExtension.setDefaults() {
    compileSdkVersion(ProjectVersions.androidSdk)
    defaultConfig {
        minSdkVersion(ProjectVersions.minSdk)
        targetSdkVersion(ProjectVersions.androidSdk)
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            isTestCoverageEnabled = false
        }
        getByName("debug") {
            isTestCoverageEnabled = false
        }
    }

    testOptions {
        unitTests.apply {
            isReturnDefaultValues = true
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }


//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_1_8.toString()
//    }

    packagingOptions {
        pickFirst("META-INF/LICENSE*")
        pickFirst("META-INF/DEPENDENCIES")
    }
}
