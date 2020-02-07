#!/bin/bash

cd ../../packages/nimbus-bridge/

npm run build

cp dist/iife/nimbus.js ../../platforms/android/nimbusjs/src/main/res/nimbus.js

exit 0