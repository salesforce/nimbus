import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.gradle.api.tasks.testing.logging.TestLogEvent.*
import org.gradle.api.tasks.testing.logging.TestExceptionFormat

// Container for tests summaries
rootProject.extra.set("testResults", mutableListOf<String>())

allprojects {
    tasks.withType<Test> {

        testLogging {
//            events = setOf(FAILED, PASSED, SKIPPED, STANDARD_OUT, STANDARD_ERROR)
            events = setOf(FAILED, PASSED, SKIPPED, STANDARD_ERROR)

            exceptionFormat = TestExceptionFormat.FULL
            showExceptions = true
            showCauses  = true
            showStackTraces = true
        }

        ignoreFailures = true // Always try to run all tests for all modules

        addTestListener(object : TestListener {
            override fun beforeTest(p0: TestDescriptor?) = Unit
            override fun beforeSuite(p0: TestDescriptor?) = Unit
            override fun afterTest(desc: TestDescriptor, result: TestResult) = Unit
            override fun afterSuite(desc: TestDescriptor, result: TestResult) {
                // Only summarize results for whole modules
                if (desc.parent == null) {
                    addResults(desc, result)
                }
            }
        })
        useJUnitPlatform()
    }
}

fun addResults(desc: TestDescriptor, result: TestResult) {
    val output = result.run {
        "Results: $resultType (" +
            "$testCount tests, " +
            "$successfulTestCount successes, " +
            "$failedTestCount failures, " +
            "$skippedTestCount skipped" +
            ")"
    }
    val testResultLine = "|  $output  |"
    val repeatLength = testResultLine.length
    val seperationLine = "-".repeat(repeatLength)
//    testResultList.add(testResultLine)
    val listOfResults = rootProject.extra.get("testResults") as MutableList<String>
    listOfResults.add(testResultLine)
    rootProject.extra.set("testResults", listOfResults)
//    println(seperationLine)
//    println(testResultLine)
//    println(seperationLine)
}

gradle.buildFinished {
    val allResults = rootProject.extra.get("testResults") as List<String>

    if (allResults.any()) {
        allResults.forEach{println(it)}
    }
}
