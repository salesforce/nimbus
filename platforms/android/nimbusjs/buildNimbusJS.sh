#!/bin/bash

cd ../../packages/nimbus-bridge/

npm run build

cp dist/iife/nimbus.js ../../platforms/android/nimbusjs/src/main/res/raw/nimbus.js

exit 0