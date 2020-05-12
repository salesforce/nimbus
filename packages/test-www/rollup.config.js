//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

/* eslint-env node */
import fs from "fs-extra";
import path from "path";
import resolve from "rollup-plugin-node-resolve";
import typescript from "rollup-plugin-typescript2";

const dist = path.resolve(__dirname, "dist", "test-www");
const publicFolder = path.resolve(__dirname, "public");
const output = path.resolve(dist, "bundle.js");

// Start with cleaning Dist folder
fs.removeSync(dist);

// Copy public folder
fs.copySync(publicFolder, dist);

const mochaPath = path.resolve(__dirname, "node_modules", "mocha");
fs.copySync(
  path.resolve(mochaPath, "mocha.css"),
  path.resolve(dist, "mocha.css")
);
fs.copySync(
  path.resolve(mochaPath, "mocha.js"),
  path.resolve(dist, "mocha.js")
);
const chaiPath = path.resolve(__dirname, "node_modules", "chai");
fs.copySync(path.resolve(chaiPath, "chai.js"), path.resolve(dist, "chai.js"));
const sharedTestsPath = path.resolve(__dirname, "test", "shared-tests.js")
fs.copySync(path.resolve(sharedTestsPath), path.resolve(dist, "shared-tests.js"))

export default {
  input: "test/index.ts",
  external: ["mocha", "chai", "nimbus-bridge"],
  output: {
    file: output,
    format: "iife",
    globals: {
      chai: "chai",
      "nimbus-bridge": "__nimbus",
    },
  },
  plugins: [resolve(), typescript()],
};
