---
layout: docs
---

# Writing a Nimbus Plugin

Plugins are how native functionality is exposed to hybrid features. Typically, plugins are small and have a single responsibility. Plugins are intended to be composable and you should keep this in mind while building your own plugins.

Making a plugin means building a class in Kotlin that implements the `Plugin` interface and is annotated properly. Annotations are used to provide binding options, and to express which functions in the native class should be bound to the webview.

---

The class declaration should include implementing the `Plugin` interface as well as the `PluginOptions` annotation.

```kotlin
@PluginOptions(name = "DeviceInfoPlugin")
class DeviceInfoPlugin(context: Context) : Plugin { ... }
```

The `name` parameter in the `PluginOptions` annotation will be the name of the object this plugin will be bound as when attached to a webview.

---

Then annotate each function you'd like to bind to the webview with the `BoundMethod` annotation.

```kotlin
@BoundMethod
    fun getDeviceInfo(): DeviceInfo {
        return cachedDeviceInfo
    }
```

Each bound function will be available in the webview with an equivalent function name. For example, the above function will be available as `getDeviceInfo`.