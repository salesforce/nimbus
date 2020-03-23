---
layout: docs
---

# iOS Installation Guide

1. Add the Nimbus framework as a dependency

Nimbus for iOS supports several distribution mechanisms in order to be easily added to any project.

_Cocoapods_

```ruby
target 'MyApp' do
  pod 'NimbusBridge', :git => 'https://github.com/salesforce/nimbus.git', :tag => '0.0.2'
end
```

_Carthage_

```ruby
github 'salesforce/nimbus' ~> 0.0.2
```

_Swift Package_

```swift
dependencies: [
  .package(url: "https://github.com/salesforce/nimbus.git", from: "0.0.2"),
]
```

2. Import the Nimbus module

```swift
import Nimbus
```

3. Initialize the Nimbus Bridge and attach it to your `WebView`:

```swift
let bridge = NimbusBridge()
bridge.addPlugin(DeviceInfoPlugin())
bridge.attach(to: webView)
webView.load(URLRequest(url: appURL))
```
