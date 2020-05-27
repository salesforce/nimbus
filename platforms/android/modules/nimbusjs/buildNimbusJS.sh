#!/bin/bash

echo "Build nimbus.js"
cd ../../packages/nimbus-bridge/

npm install

npm run build

mkdir ../../platforms/android/modules/nimbusjs/src/main/res/raw/

cp dist/iife/nimbus.js ../../platforms/android/modules/nimbusjs/src/main/res/raw/nimbus.js

exit 0
