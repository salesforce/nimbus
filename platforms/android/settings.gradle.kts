rootProject.name = "Nimbus"

arrayOf(":bridge-webview", ":annotations", ":compiler-webview", ":nimbusjs", ":core",
    ":compiler-base", ":bridge-v8", ":compiler-v8", ":core-plugins"
).forEach { include(":modules$it") }

include(":demo-app", ":shared-tests")
