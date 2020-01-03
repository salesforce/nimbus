import typescript from "rollup-plugin-typescript2";

const es5iife = {
  plugins: [
    typescript({
      tsconfigOverride: {
        compilerOptions: {
          target: "es5"
        }
      }
    })
  ],
  input: "src/index.ts",
  output: [
    {
      file: "dist/iife/nimbus.js",
      name: "nimbus",
      format: "iife"
    }
  ]
};

const es6esm = {
  plugins: [typescript()],
  input: "src/index.ts",
  output: [
    {
      file: "dist/es/nimbus.js",
      format: "es"
    }
  ]
};

export default [es5iife, es6esm];
