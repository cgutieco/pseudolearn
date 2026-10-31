import { readdirSync } from "node:fs";
import { extname, join } from "node:path";

const codeExtensions = new Set([".ts", ".tsx", ".js", ".mjs", ".cjs"]);
const ignoredDirectories = new Set([".git", ".artifacts", ".vscode-test-web", "bin", "dist", "node_modules", "test-results", "__fixtures__"]);

export function codeFiles(root) {
  const files = [];
  visit(root, files);
  return files;
}

function visit(directory, files) {
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory() && !ignoredDirectories.has(entry.name)) {
      visit(path, files);
    } else if (entry.isFile() && codeExtensions.has(extname(entry.name))) {
      files.push(path);
    }
  }
}
