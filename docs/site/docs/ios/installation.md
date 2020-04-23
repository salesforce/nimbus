---
layout: docs
---

# iOS Installation Guide

1. Add the Nimbus framework as a dependency

Nimbus for iOS supports several distribution mechanisms in order to be easily added to any project.

_Cocoapods_

```ruby
target 'MyApp' do
  pod 'NimbusBridge', :git => 'https://github.com/salesforce/nimbus.git', :tag => '1.0.0'
end
```

_Carthage_

```ruby
github 'salesforce/nimbus' ~> 1.0.0
```

_Swift Package_

```swift
dependencies: [
  .package(url: "https://github.com/salesforce/nimbus.git", from: "1.0.0"),
]
```

2. Import the Nimbus module

```swift
import Nimbus
```

3. Initialize the Nimbus Bridge and attach it to your `WebView`:

```swift
let bridge = WebViewBridge()
bridge.addPlugin(DeviceInfoPlugin())
bridge.attach(to: webView)
webView.load(URLRequest(url: appURL))
```

# NimbusJS

NimbusJS is a framework provided via CocoaPods (other package managers will be supported later) to make it easy to inject the nimbus.js source into your hybrid container.

_Installation_
1. Add the NimbusJS framework as a dependency
```ruby
target 'MyApp' do
  pod 'NimbusJS', :git => 'https://github.com/salesforce/nimbus.git', :tag => '1.0.0'
end
```

2. Import the Nimbus module

```swift
import NimbusJS
```

3. Inject the nimbus.js source

```swift
do {
  try webView.injectNimbusJavascript()
} catch {
  fatalError()
}
```