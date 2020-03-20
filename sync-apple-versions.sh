#!/bin/bash

FULL_VERSION="$(grep -Ei '\"version\": \"([.0-9]+)\"' lerna.json)"
VERSION="$(echo ${FULL_VERSION}\ | grep -E -o '[0-9]+.[0-9]+.[0-9]')"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" platforms/apple/Sources/Nimbus/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" platforms/apple/Sources/NimbusJS/Info.plist