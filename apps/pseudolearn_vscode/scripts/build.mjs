import { build } from "esbuild";
import { resolve } from "node:path";

const extensionRoot = process.cwd();

await build({
  entryPoints: [resolve(extensionRoot, "src/activation/extension.ts")],
  bundle: true,
  platform: "node",
  target: "node22",
  format: "cjs",
  external: ["vscode"],
  outfile: resolve(extensionRoot, "dist/extension.js"),
});
