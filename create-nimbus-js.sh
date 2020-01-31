#!/bin/bash

#remove old NimbusJS.zip if it exists
rm NimbusJS.zip

# compile nimbus.js
cd packages/nimbus-bridge
npm run build
cd ../../

# zip nimbus.js
zip -j NimbusJS.zip packages/nimbus-bridge/dist/iife/nimbus.js

# zip the webview extension
zip -j NimbusJS.zip platforms/apple/Sources/NimbusJS/WebView+NimbusJS.swift

# zip the license
zip -j NimbusJS.zip LICENSE