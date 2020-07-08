#!/bin/bash

cd ../../packages/nimbus-bridge/ || exit

npm install

npm run build

mkdir ../../platforms/android/modules/nimbusjs/src/main/assets

cp dist/iife/nimbus.js ../../platforms/android/modules/nimbusjs/src/main/assets/nimbus.js

exit 0
