
# Nimbus Bridge Design

Both iOS and Android provide facilities for communicating between
native code and JavaScript in their SDKs, but each works differently.
Lack of a consistent pattern to follow increases the difficulty of
writing JavaScript code for mobile that works on either platform. An
examination of the standard platform approaches is below, followed by
a design for a thin, consistent abstraction on top of these
platform-provided APIs.

## Platform Default Bridging APIs

### Android

Android's [`WebView`][WebView] is the standard way of embedding a web
application into an Android app. `WebView` supports binding Java code
to JavaScript via the [`@JavascriptInterface`][JavascriptInterface]
annotation on methods to be exposed to JavaScript and the
[`addJavascriptInterface()`][addJavascriptInterface] method on
`WebView`. Documentation on the `@JavascriptInterface` annotation and
details around how parameter and return types are converted to
JavaScript is sparse.

Use of this API is very straightforward both from the Java and
JavaScript sides:

```kotlin
class Bridge {
    @JavascriptInterface
    fun hello(name: String): String {
        return "Hello, " + name
    }
}

webView.addJavascriptInterface(Bridge(), "bridge")
```

```javascript
console.log( bridge.hello("world") );
```

Using this binding interface makes it possible to both accept
parameters and return results to JavaScript in a synchronous manner.

[WebView]: https://developer.android.com/reference/android/webkit/WebView
[JavascriptInterface]: https://developer.android.com/reference/android/webkit/JavascriptInterface
[addJavascriptInterface]: https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)

### iOS

On iOS [`WKWebView`][WKWebView] is currently the standard and
recommended way of embedding a web application into a native app.
`WKWebView` supports only asynchronous message passing between
JavaScript and native code due to `WKWebView` executing in a separate
process for isolation. It is possible for native code to register as a
message handler via the
[`WKScriptMessageHandler`][WKScriptMessageHandler] protocol and
[`WKUserContentController`][WKUserContentController] class.

Use of this API is fairly straightforward, but more cumbersome than
the Android example due to everything being an asynchronous message:

```swift
class Bridge : WKScriptMessageHandler {
    init() {
        // ... WKWebView setup elided
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "hello")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch (message.name) {
        case "hello":
            let name = message.body as? String
            let greeting = "Hello, \(name)"
            webview.evaluateJavascript("window.HelloCallback('\(greeting)')", callback:nil)
        default:
            break
        }
    }
}

```

```javascript
window.HelloCallback = function (text) {
  console.log(text);
}
window.webkit.messageHandlers.hello("world");
```

Immediately some limitations of the iOS approach are apparent. There
is no ability to directly return a value from a script message
handler. Only one argument is accepted, which is the message body.
"Returning" a value to JavaScript must be accomplished by evaluating a
new chunk of JavaScript code and embedding the result into that
string. Nowhere in the `Bridge` interface is it readily apparently
what the signature of the bridge `hello` method is.

Nimbus aims to address these issues and provide a consistent
cross-platform bridging system.

[WKWebView]: https://developer.apple.com/documentation/webkit/wkwebview
[WKScriptMessageHandler]: https://developer.apple.com/documentation/webkit/wkscriptmessagehandler
[WKUserContentController]: https://developer.apple.com/documentation/webkit/wkusercontentcontroller

## Bridgeable Function Call Patterns

Nimbus's primary purpose is making native code callable from
JavaScript, with the ability to return results and execute callbacks.
Exposing JavaScript code as a native API is currently not within the
scope of this project.

There are several function calling patterns that will be supported.

### Function call with no return value

The most basic function calling pattern is one with zero or more
arguments and no return value. This pattern maps directly onto message
passing.

```javascript
bridge.foo("hello", 1, 2);
```

```kotlin
class Bridge {
    fun foo(p0: String, p1: Int, p2: Int) { ... }
}
```

```swift
class Bridge {
    func foo(p0: String, p1: Int, p2: Int) { ... }
}
```

The Android bridge supports this binding style already. iOS would need only
to insert a shim function into Javascript under the correct name that
would forward a call to `webkit.messageHandlers`. In Android this call
would execute synchronously but on iOS it would execute
asynchronously. It may be desirable to write code that waits until
execution of the function is complete which would involve returning a
`Thenable` that could be used from the calling code. This would align
well with the next binding style where a return value is expected from
the function.

```javascript
bridge.foo("hello").then(() => { /* done! */ });
// or
await bridge.foo();
```

### Function call with return value

The next calling pattern is one that takes zero or more arguments and
returns a result value.

```javascript
let result = bridge.bar();
```

```kotlin
class Bridge {
    fun bar(): String { return "yo" }
}
```

```swift
class Bridge {
    func bar() -> String { return "yo" }
}
```

This pattern is also supported directly by Android, however the async
message passing on iOS makes this impossible to implement directly.
Instead, native functions that return a value will need to map to
JavaScript `Promise`s. On Android we can use a lightweight `Thenable`
to simply pass back the synchronous return value, and use actual
promises on iOS to wrap the async return.

Note that the native functions in this scenario are still written to
return a value synchronously, the use of a `Thenable` or `Promise` is
hidden inside the bridge code.

```javascript
bridge.bar().then((result) => { });
// or
let result = await bridge.bar();
```

### Function call with function arguments (aka callbacks)

Some functions need to perform asynchronous execution, such as making
a network call or database query, and return a result once it is
available.

```javascript
bridge.baz((result) => { console.log(result); });
```

```kotlin
class Bridge {
    fun baz(callback: Callback) {
        // do some stuff
        callback("yo");
    }
}
```

```swift
class Bridge {
    func baz(callback: Callback) {
        // do some stuff
        callback("yo");
    }
}
```

Neither the Android nor iOS web view APIs support this pattern
directly. The Nimbus bridge will provide a means to register the
JavaScript callback and pass a proxy object into native functions that
can be used to invoke the callback as desired.

### Function call with Observable return [maybe]

```javascript
bridge.baz().subscribe(
  (next) => { console.log(next); },
  (err) => { console.err(err); },
  () => { console.log("done!"); }
);
```

```kotlin
class Bridge {
    fun baz(): Observable {
        // do some stuff
        observable.emit("yo");
        observable.emit("hey");
        observable.completed();
    }
}
```

```swift
class Bridge {
    func baz() -> Observable {
        // do some stuff
        observable.emit("yo");
        observable.emit("hey");
        observable.completed();
    }
}
```

## Bridging Callbacks

Since neither Android nor iOS support sending a callback function
across the bridge it is necessary to device a technique for storing a
callback in JavaScript, passing a unique identifier across the bridge,
and later using that token to look up and invoke the callback.

This pattern is simple to implement, similar to the following:

```javascript
let callbacks = {};
let token = "callback_" + Math.floor(Math.random() * 100000);
callbacks[token] = (result) => { console.log('callback!'); };

bridge.method(arg1, arg2, token);
```

```kotlin
class Bridge {
    fun method(arg1: String, arg2: String, cbToken: String) {
        val result = "something"
        webView.evaluateJavascript("callbacks[$cbToken]('$result');");
    }
}
```

This exposes the details of how callbacks are bridged to both the
implementor of the native code and to the javascript code calling it.
Ideally the bridge will generate the necessary stubs when bindings are
created so that the code would look more like the following example:

```javascript
bridge.method(arg1, arg2, (result) => { console.log(result); });
```

```kotlin
class Bridge {
    fun method(arg1: String, arg2: String, callback: ???) {
        val result = "something"
        callback(result)
    }
}
```

### Lifetime and Memory Management

Because callback functions passed from JavaScript to native are being
held in a global map, care must be taken not to leak the callback
object. The token passed across the bridge should be owned by an
object in the native code that will delete the callback from
JavaScript at the end of its lifetime to ensure cleanup happens.

## Android Native API

TBD
