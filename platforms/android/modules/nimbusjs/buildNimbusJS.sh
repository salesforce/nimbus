#!/bin/bash

echo "Build nimbus.js"
cd ../../packages/nimbus-bridge/

npm install

npm run build

mkdir ../../platforms/android/nimbusjs/src/main/assets

cp dist/iife/nimbus.js ../../platforms/android/nimbusjs/src/main/assets/nimbus.js

exit 0
