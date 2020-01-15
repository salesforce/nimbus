# Supporting reject state for promise created with trailing closure

Nimbus currently has a way to turn a native method into Javascript method that returns a promise.  For example let's say that we have a method `foo` in iOS:
```swift
func foo(@escaping callback: (success: String) -> Void) {...}
```
and a counterpart in Android:
```kotlin
fun foo(callback: (success: String) -> Unit) {...}
```
For these two methods to be converted into a method that returns a promise in Javascript we need to bind `foo`, for iOS, and indicate that the closure that was passed as a parameter is for promise:
```swift
connection.bind(foo, as: "foo", trailingClosure: .promise)
```
And for Android we need to annotate `foo` with:
```kotlin
@ExtensionMethod(trailingClosure = TrailingClosure.PROMISE)
func foo(callback: (success:String) -> Unit) {...}
```
In Javascript the above would translate into code like this:
```javascript
const promise = foo()
```
But because this promise currently only supports the resolve state but not the reject state it is only then-able:
```javascript
// Doable:
foo().then((success) -> {console.log(success);})
// Not doable:
foo().catch((error) -> {console.log(error);})
// Also not doable:
foo().then((success) -> {console.log(success);}).catch((error) -> {console.log(error);})
```

This RFC lists and explores 3 distinct approaches to support reject state in Nimbus.

**(1) Method that Throws**

If a method is declared to throw and is designated as a trailing closure,
in iOS:
```swift
func foo(@escaping callback: (success: String) -> ()) throws {...}
connection.bind(foo, as: "foo", trailingClosure: .promise)
```
in Android:
```kotlin
@Throws(IOException::class)
@ExtensionMethod(trailingClosure = TrailingClosure.PROMISE)
fun foo(callback: (success: String) -> Unit) {...}
```
then we can consider that promise for these methods will need to support both resolve and reject. All exceptions will be converted into 'something'(string message??).

Pro: Fairly easy to implement.  
Con: Exception thrown will lose information when it gets to Javascript as a string message. What type of data should reject state pass back??

**(2) Closure with Two Arguments**

If a method is passed a closure with two arguments and this closure is indicated as promise
in iOS:
```swift
func foo(@escaping callback: (success: String?, error: String?) -> ()) {...}
connection.bind(foo, as: "foo", trailingClosure: .promise)
```
in Android:
```kotlin
@ExtensionMethod(trailingClosure = TrailingClosure.PROMISE)
fun foo(callback: (success: String?, error: String?) -> ()) {...}
```
then we can use this same closure to callback for both resolved and rejected states.  The distinction for the two states are made by one of the arguments to the closure being a null but not both.

Pro: Fairly easy to implement.  
Con: Should the type for error parameter be constrained to specific type???

**(3) Second Closure As Parameter**

If a method is passed **two** closures and these closures are marked for the promise's resolve and reject callbacks,
in iOS:
```swift
func foo(@escaping success: (String) -> (), @escaping error: (String) -> ()) {...}
connection.bind(foo, as: "foo", trailingClosure: .promiseResolveAndReject)
```
in Android:
```kotlin
@ExtensionMethod(trailingClosure = TrailingClosure.PROMISE_RESOLVE_AND_REJECT)
fun foo(success: (String) -> Unit, error: (String) -> Unit) {...}
```
then we can use respective closure to notify resolve and reject states.

Pro: Easier to read than the previous 2 approaches.  
Con: More code to write than the previous 2 approaches.

