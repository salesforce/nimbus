#!/bin/bash

cd ../../packages/nimbus-bridge/

npm install

npm run build

mkdir ../../platforms/android/nimbusjs/src/main/res/raw/

cp dist/iife/nimbus.js ../../platforms/android/nimbusjs/src/main/res/raw/nimbus.js

exit 0