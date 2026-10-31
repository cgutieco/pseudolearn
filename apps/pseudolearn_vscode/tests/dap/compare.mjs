import { deepStrictEqual } from "node:assert";
import { readFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

export function compare(left, right) {
  deepStrictEqual(left, right, "DAP clients disagree on source, task, order, location, revision, result or error");
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const [left, right] = await Promise.all(process.argv.slice(2, 4).map(async (path) => JSON.parse(await readFile(path, "utf8"))));
  if (!left || !right) throw new Error("Usage: node tests/dap/compare.mjs <VS-Code-projection> <stdio-projection>");
  compare(left, right);
  process.stdout.write("DAP client projections match\n");
}
