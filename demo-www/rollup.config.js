//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

/* eslint-env node */
import fs from "fs-extra";
import path from "path";
import lwcCompiler from "@lwc/rollup-plugin";
import resolve from "rollup-plugin-node-resolve";
import replace from "rollup-plugin-replace";
import serve from "rollup-plugin-serve";

const dist = path.resolve(__dirname, "./dist");
const publicFolder = path.resolve(__dirname, "./public");
const output = path.resolve(dist, "./bundle.js");
const isWatching = process.env.ROLLUP_WATCH;

// Start with cleaning Dist folder
fs.removeSync(dist);

// Copy public folder
fs.copySync(publicFolder, dist);

export default {
  input: "src/index.js",
  output: { file: output, format: "iife" },
  plugins: [
    resolve({ main: true }),
    lwcCompiler({ resolveFromPackages: true }),
    replace({ "process.env.NODE_ENV": JSON.stringify("development") }),
    isWatching && serve({ contentBase: dist, open: false, host: '0.0.0.0', port: 3000 })
  ].filter(Boolean)
};
