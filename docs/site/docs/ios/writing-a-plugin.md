---
layout: docs
---
# Writing a Nimbus Plugin

Plugins are how native functionality is exposed to hybrid features. Typically, plugins are small and have a single responsibility. Plugins are intended to be composable and you should keep this in mind while building your own plugins.

Making a plugin means building a class in Swift that conforms to the `NimbusExtension` protocol shown below. Any conforming types must be of a class type in order to implement the protocol. Your plugin should import `WebKit` and `Nimbus`.

```swift
@objc public protocol NimbusExtension {
    func bindToWebView(webView: WKWebView)
}
```
_____
In the `bindToWebView` implementation, you should call `addConnection` on `WKWebView` which is made available from an extension in the `Nimbus` framework.

```swift
let connection = webView.addConnection(to: self, as: "dharmaPlugin")
```

The first parameter to `addConnection` specifies which instance the connection is mapped to. The second parameter specifies what the name this connection will be available as in the webview. This will be the object your javascript code will call functions on to access functionality exposed by this plugin.
_____
Then call `bind` on the resulting connection for each function you want to be bound to the webview.

```swift
connection.bind(DharmaPlugin.theNumbers, as: "theNumbers")
```

The first parameter is the method you want to bind, and the second parameter is the name you want the method bound to. This will be the function name your javascript code will call to invoke this method.
_____
You can bind methods with a return value. On the javascript side, a bound method with a return value will return a promise, which is resolved when the bound method returns.

```javascript
dharmaPlugin.theNumbers()
  .then(function (theNumbers){
    alert("numbers: " + theNumbers);
  });
```
_____
You can bind methods that take a closure as their last parameter. On the javascript side, the function passed as the last parameter is treated as a completion block and is invoked when the completion block is called on the native side.

```javascript
dharmaPlugin.checkBoat(
  function (boatName) {
    alert(boatName + " boat");
  });
```

Any native parameters or return types must conform to `Encodable` in order for them to be bound. You can bind methods with up to 5 parameters, the last of which can be a callback. If you need more parameters than is available, it's recommended that you build an `Encodable` struct to wrap the necessary context.

The native plugin and example javascript calling that plugin are included in their entirety below.
_____

##### DharmaPlugin.swift
```swift
import Foundation
import WebKit
import Nimbus

class DharmaPlugin {
    func theNumbers() -> [Int] {
        return [4, 8, 15, 16, 23, 42]
    }

    func checkBoat(boatToCheck: String, callback: @escaping (_ boatName: String) -> Void) {
        boatCheck(boatToCheck: boatToCheck) { boatName in
            callback(boatName)
        }
    }
}

extension DharmaPlugin: NimbusExtension {
    func bindToWebView(webView: WKWebView) {
        let connection = webView.addConnection(to: self, as: "dharmaPlugin")
        connection.bind(DharmaPlugin.theNumbers, as: "theNumbers")
        connection.bind(DharmaPlugin.checkBoat, as: "checkBoat")
    }
}

extension DharmaPlugin {
    func boatCheck(boatToCheck: String, _ completion: @escaping (_ boatName: String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            let result = boatToCheck == "Penny" ? "Penny's" : "Not Penny's"
            completion(result)
        }
    }
}
```

```html
<head>
</head>
<style>
    .big {
        width: 100%;
        height: 200px;
    }
</style>
<body>
    <script>
    function callNumbers() {
        if (typeof dharmaPlugin !== 'undefined') {
            dharmaPlugin.theNumbers().then(function (theNumbers){
              alert("numbers: " + theNumbers);
            });
        }
    }
    function checkPennys() {
        if (typeof dharmaPlugin !== 'undefined') {
        dharmaPlugin.checkBoat("Penny", function (boatName) {
          alert(boatName + " boat");
          });
        }
    }
    function checkJacks() {
        if (typeof dharmaPlugin !== 'undefined') {
          dharmaPlugin.checkBoat("Jack", function (boatName) {
            alert(boatName + " boat");
          });
        }
    }
    </script>
    <h1>Here is the page</h1>
    <button class="big" onclick="callNumbers()">Numbers</button>
    <br>
    <button class="big" onclick="checkPennys()">Penny's</button>
    <br>
    <button class="big" onclick="checkJacks()">Jack's</button>
</body>
```
