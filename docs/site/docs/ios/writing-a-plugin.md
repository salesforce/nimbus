---
layout: docs
---

# Writing a Nimbus Plugin

Plugins are how native functionality is exposed to hybrid features. Typically, plugins are small and have a single responsibility. Plugins are intended to be composable and you should keep this in mind while building your own plugins.

Making a plugin means building a class in Swift that conforms to the `Plugin` protocol. Any conforming types must be of a class type in order to implement the protocol. Your plugin should import `WebKit` and `NimbusBridge`.

---

In the `bind(to:)` implementation, you should call `bind` on `Connection` for each function you want to be bound to the web view.

```swift
connection.bind(self.theNumbers, as: "theNumbers")
```

The first parameter is the function you want to bind, and the second parameter is the name you want the method bound to. This will be the function name your javascript code will call to invoke this method.

---

You can bind methods with a return value. On the javascript side, a bound method with a return value will return a promise, which is resolved when the bound method returns.

```javascript
dharmaPlugin.theNumbers().then(theNumbers => {
    alert(`numbers: ${theNumbers}`);
});
```

---

You can bind methods that take a closure as their last parameter. On the javascript side, the function passed as the last parameter is treated as a completion block and is invoked when the completion block is called on the native side.

```javascript
dharmaPlugin.checkBoat("Penny", boatName => {
    alert(`${boatName} boat`);
});
```

Any parameters to native bound methods must conform to `Decodable`. Return types must conform to `Encodable` in order for them to be bound. You can bind methods with up to 5 parameters, the last of which can be a callback. If you need more parameters than is available, it's recommended that you build an `Decodable` struct to wrap the necessary context.

The native plugin and example javascript calling that plugin are included in their entirety below.

---

##### DharmaPlugin.swift

```swift
import Foundation
import WebKit
import NimbusBridge
import JavaScriptCore

struct DharmaMessage: Encodable {
    var stringField = "This is a string"
    var intField = 42
}

class DharmaPlugin {
    func theNumbers() -> [Int] {
        return [4, 8, 15, 16, 23, 42]
    }

    func checkBoat(boatToCheck: String, callback: @escaping (_ boatName: String, _ numberParam: Int) -> Void) {
        boatCheck(boatToCheck: boatToCheck) { boatName, number, arrayOfNumbers  in
            callback(boatName, number)
        }
    }

    func callbackWithSingleParam(completion: @escaping (DharmaMessage) -> Void) {
        completion(DharmaMessage())
    }
}

extension DharmaPlugin: Plugin {
    func bindToJSContext(context: JSContext) {
        // do nothing
    }

    var namespace: String {
        return "dharmaPlugin"
    }

    func bind<C>(to connection: C) where C : Connection {
        connection.bind(self.theNumbers, as: "theNumbers")
        connection.bind(self.checkBoat, as: "checkBoat")
        connection.bind(self.callbackWithSingleParam, as: "callbackWithSingleParam")
    }
}

extension DharmaPlugin {
    func boatCheck(boatToCheck: String, _ completion: @escaping (_ boatName: String, _ numberParam: Int, _ arrayParam: [Int]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let result = boatToCheck == "Penny" ? "Penny's" : "Not Penny's"
            completion(result, 1, [2, 3, 4])
        }
    }
}
```

```html
<head> </head>
<style>
    .big {
        width: 100%;
        height: 200px;
    }
</style>
<body>
    <script>
        function callNumbers() {
            if (typeof __nimbus.plugins.dharmaPlugin !== 'undefined') {
                __nimbus.plugins.dharmaPlugin.theNumbers().then(function (theNumbers){
                                            alert("numbers: " + theNumbers);
                                            });
            }
        }
        function checkPennys() {
            if (typeof __nimbus.plugins.dharmaPlugin !== 'undefined') {
                __nimbus.plugins.dharmaPlugin.checkBoat("Penny", function (boatName) {
                                alert(boatName + " boat");
                                });
                }
        }
        function checkJacks() {
            if (typeof __nimbus.plugins.dharmaPlugin !== 'undefined') {
                __nimbus.plugins.dharmaPlugin.checkBoat("Jack", function (boatName) {
                    alert(boatName + " boat");
                });
            }
        }   
    </script>
    <h1>Here is the page</h1>
    <button class="big" onclick="callNumbers()">Numbers</button>
    <br />
    <button class="big" onclick="checkPennys()">Penny's</button>
    <br />
    <button class="big" onclick="checkJacks()">Jack's</button>
</body>
```
