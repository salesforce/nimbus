import typescript from "rollup-plugin-typescript2";

export default {
  plugins: [typescript()],
  input: "src/index.ts",
  output: [
    {
      file: "dist/iife/nimbus.js",
      name: "nimbus",
      format: "iife"
    },
    {
      file: "dist/es/nimbus.js",
      format: "es"
    }
  ]
};
