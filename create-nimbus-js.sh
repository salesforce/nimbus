#!/bin/bash

#remove old NimbusJS.zip if it exists
rm NimbusJS.zip

# compile nimbus.js
pushd packages/@nimbus-js/runtime
npm run build
popd

# zip nimbus.js
zip -j NimbusJS.zip packages/@nimbus-js/runtime/dist/iife/nimbus.js

# zip the webview extension
zip -j NimbusJS.zip platforms/apple/Sources/NimbusJS/WebView+NimbusJS.swift

# zip the license
zip -j NimbusJS.zip LICENSE
