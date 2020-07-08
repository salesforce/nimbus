---
layout: docs
---

# Android Installation Guide

#### 1. Add the maven repository to your project's `build.gradle`:

```groovy
allprojects {
    repositories {
        maven { url  "https://dl.bintray.com/salesforce-mobile/android" }
    }
}
```

<details>
<summary>
Click for details on SNAPSHOT builds
</summary>

Add the following to your `build.gradle` to consume a snapshot of Nimbus

```kts
plugins {
    id("com.jfrog.artifactory") version "version"
}
allprojects {
    apply plugin: "com.jfrog.artifactory"
}
artifactory {
    contextUrl = 'http://oss.jfrog.org'
    resolve {
        repository {
            repoKey = 'libs-snapshot'
        }
    }
}
```

</details>

#### 2. Add the `kotlin-kapt` plugin to your app's `build.gradle`:

```groovy
apply plugin: 'kotlin-kapt'
```

or

```kts
plugins {
    kotlin("kapt")
}
```

#### 3. Add the Nimbus runtime dependency and annotation processor to your app's `build.gradle`:

```kts
dependencies {
    // include bridge and compiler for webview or j2v8
    val bridgeType = "webview" // or "v8"
    implementation("com.salesforce.nimbus:bridge-$bridgeType:$nimbusVersion")
    kapt("com.salesforce.nimbus:compiler-$bridgeType:$nimbusVersion")

    // optionally add core plugins
    implementation("com.salesforce.nimbus:core-plugins:$nimbusVersion")
}
```

#### 4. Initialize the Nimbus Bridge and attach it to your `WebView`:

```kotlin
class MainActivity : AppCompatActivity() {

    private lateinit var bridge: WebViewBridge // or V8Bridge

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val webView = findViewById<WebView>(R.id.webview)

        // create instance of core plugin
        val deviceInfoPlugin = DeviceInfoPlugin(this)

        bridge = webView.bridge {
            bind {
                deviceInfoPlugin.webViewBinder()
                // or deviceInfoPlugin.v8Binder()
            }
        }

        webView.loadUrl("http://10.0.2.2:3000")
        // or create v8 and executeScript
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge.detach()
    }
}
```

# NimbusJS

1. Add NimbusJS to your app's `build.gradle`:

```kts
dependencies {
    implementation("com.salesforce.nimbus:nimbusjs:$nimbusVersion")
}
```

2. Inject nimbus.js:

You can refer directly to the nimbus.js source included as a resource in the NimbusJS AAR or you can use `NimbusJSUtilities.injectedNimbusStream(...)` to inject nimbus.js into a page load stream intercepted in your webview.
