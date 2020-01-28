# Distributing nimbus.js to native consumers

In order for nimbus to work, the `nimbus.js` file that is the build output of the TypeScript project has to be present as a resource in any webpage that wants to use hybrid features. 

The current, officially supported way that we do this is to add nimbus as an npm dependency on the web app and load `nimbus.js` in the page itself. This is not a perfect solution, as it could lead to native containers getting out of sync with the version of nimbus loaded in the webview. Most use cases would be better suited to loading `nimbus.js` from the hybrid container itself.

We don't currently have any officially supported way for native consumers to import this compiled artifact. Current consumers are building the source themselves and manually copying it into their projects.

This RFC discusses a number of options to enable this on both iOS and Android.

**The decision is to move forward with Option 2 for iOS and the single proposed option on Android**

# iOS

**1 - Podspec with a `prepare_command` step**

```ruby
spec.prepare_command = <<-CMD
                        # curl and unzip here
                   CMD
```

`prepare_command` is fairly stable and well supported, documentation [here](https://guides.cocoapods.org/syntax/podspec.html#prepare_command). The command step would pull the nimbus.js artifact from the GitHub releases page. We don't currently publish the compiled nimbus.js to the releases page, this option would require us to. The resulting file would then be included in the pod as a resource that could then be included in consumer app targets.

Pros: 
- Flexible and wouldn't need to have any complicated logic to make sure the script isn't running too often, since it only gets executed once during `pod install`

Cons: 
- This is not technically the intended use of `prepare_command`
- Requires a non-trivial amount of effort to publish artifacts or automate releases (which we should probably do anyway)

**2 - Podspec with a source specification - Chosen Option**

```ruby
spec.source = { :http => 'https://github.com/salesforce/nimbus/archive/0.0.7.zip' }
```

The `source` [specification](https://guides.cocoapods.org/syntax/podspec.html#source) in a podspec can point to a zip file, which is automatically unzipped and the resulting files compose the pod source. This would be the simplest pod, in that we're using `source` for exactly what it's intended. It would require us to amend our workflow when publishing releases.

This new pod, which contains just the `nimbus.js` source, would be added as a dependency in the main nimbus podspec. We would then create convenvience utilities to inject the nimbus source into a `WKWebView` instance as a `WKUserScript`. This would simplify nimbus adoption for most consumers.

Pros: 
- Easy, and uses podspec source tag for exactly what it's intended for.

Cons: 
- Requires a non-trivial amount of effort to publish artifacts or automate releases (which we should probably do anyway)

**3 - Podspec with a script phase**

```ruby
spec.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"' }
```
the `script_phase` [specification](https://guides.cocoapods.org/syntax/podspec.html#script_phases) allows a pod author to include a script phase to add to the workspace build settings. We could use this to download the artifact zip and add the nimbus code as a source file. I mostly include this option for completeness as it has considerable downsides and no discernible upsides.

Pros: 
- Flexible

Cons: 
- Causes a warning in the `pod install` process. Invasive to consumers.
- Need to rely on Xcode features to not run this build phase more often than needed.

# Android

**1 - New Nimbus Module - Chosen Option**

We could add a new module to the Nimbus Android project. This module would contain a single Loader class that would vend the `nimbus.js` source. At build time, the module would build the nimbus js source locally and include it as a resource in the resulting AAR. This module would also contain utilities to automatically inject the nimbus script into the `<head>` tag of a loading page. Ideally, this behavior would be the default, but also optional for consumers who wish to inject the nimbus js differently.

Pros: 
- Fairly simple, seems to be idiomatic for the platform

Cons: 
- Adds complication to the project and is another module for consumers to import.
