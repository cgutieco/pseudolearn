import { defineConfig } from "vitest/config";
import { fileURLToPath } from "node:url";

const modules = (path) => fileURLToPath(new URL(`./node_modules/${path}`, import.meta.url));

export default defineConfig({
  resolve: {
    alias: {
      "vscode-languageclient/browser": modules("vscode-languageclient/lib/browser/main.js"),
      "vscode-languageserver-protocol/browser": modules("vscode-languageserver-protocol/lib/browser/main.js"),
    },
  },
});
