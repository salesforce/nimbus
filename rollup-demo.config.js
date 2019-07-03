import fs from "fs-extra";
import path from "path";
import serve from "rollup-plugin-serve";
import typescript from "rollup-plugin-typescript2";
import alias from "rollup-plugin-alias";

const isWatching = process.env.ROLLUP_WATCH;
const dist = path.resolve(__dirname, "./demo-www/dist");
const publicFolder = path.resolve(__dirname, "./demo-www/public");

// Copy public folder
fs.copySync(publicFolder, dist);

const iife = {
  input: "demo-www/src/index.ts",
  output: {
    file: "demo-www/dist/bundle.js",
    format: "iife"
  },
  plugins: [
    alias({
      nimbus:"./src/index"
    }),
    typescript({
      tsconfig: "./demo-www/tsconfig.json"
    }),
    isWatching &&
      serve({ contentBase: dist, open: false, host: "0.0.0.0", port: 3000 })
  ].filter(Boolean)
};

export default [iife];
