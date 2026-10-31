import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import { spawnSync } from "node:child_process";
import { build } from "esbuild";
import { hash } from "../../scripts/lib/web-artifact.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const require = createRequire(resolve(root, "tests/web/runner/package.json"));
const campaign = JSON.parse(readFileSync(resolve(root, "tests/web/campaign.json"), "utf8"));
const runnerPackage = require.resolve("@vscode/test-web/package.json");
const runner = JSON.parse(readFileSync(runnerPackage, "utf8"));
if (runner.version !== campaign.runner || !/^[0-9a-f]{40}$/.test(campaign.vscodeCommit)) throw new Error("Web runner or VS Code pin mismatch");
const stage = resolve(root, ".artifacts/web-extension");
for (const path of ["package.json", "dist/web/browser_extension.js", "dist/web/language_worker.js", "dist/web/execution_worker.js"]) {
  if (!existsSync(resolve(stage, path))) throw new Error(`Missing product artifact ${path}`);
}
await build({ entryPoints: [resolve(root, "tests/web/index.ts")], outfile: resolve(root, "dist/web/test/index.js"),
  bundle: true, platform: "browser", format: "cjs", external: ["vscode"], legalComments: "none" });
const output = resolve(root, "test-results/web", new Date().toISOString().replace(/[:.]/g, "-"));
mkdirSync(output, { recursive: true });
const records = [];
for (const browser of campaign.browsers) {
  const result = spawnSync(process.execPath, [resolve(dirname(runnerPackage), runner.bin["vscode-test-web"]),
    `--browser=${browser}`, `--quality=${campaign.quality}`, `--commit=${campaign.vscodeCommit}`,
    `--extensionDevelopmentPath=${stage}`, `--extensionTestsPath=${resolve(root, "dist/web/test/index.js")}`,
    "--headless", resolve(root, "tests/fixtures/web/project")], { cwd: root, encoding: "utf8", timeout: 300000 });
  writeFileSync(resolve(output, `${browser}.log`), `${result.stdout ?? ""}\n${result.stderr ?? ""}`);
  records.push({ browser, exitCode: result.status, signal: result.signal, error: result.error?.message,
    status: result.status === 0 ? "passed" : "not-qualified", logSha256: hash(resolve(output, `${browser}.log`)) });
}
writeFileSync(resolve(output, "manifest.json"), `${JSON.stringify({ ...campaign, records, provenance: JSON.parse(readFileSync(resolve(root, ".artifacts/web-provenance.json"), "utf8")) }, null, 2)}\n`);
process.stdout.write(`${output}\n`);
if (records.some((record) => record.exitCode !== 0)) process.exitCode = 1;
