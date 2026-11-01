import { cpSync, existsSync, mkdirSync, readdirSync, rmSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";
import { spawn } from "node:child_process";
import { build } from "esbuild";
import { hash } from "../../scripts/lib/web-artifact.mjs";
import { startHttpFixture } from "./http-fixture.mjs";

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
const hostStage = resolve(root, ".artifacts/web-host-test");
rmSync(hostStage, { recursive: true, force: true });
cpSync(stage, hostStage, { recursive: true });
const testBundle = resolve(hostStage, "dist/web/test/index.js");
const scenarioRoot = resolve(root, "tests/fixtures/web-scenarios");
function scenarioSources(relative = "") {
  return readdirSync(join(scenarioRoot, relative)).flatMap((name) => {
    const path = join(relative, name);
    return statSync(join(scenarioRoot, path)).isDirectory() ? scenarioSources(path)
      : [[path.split("\\").join("/"), readFileSync(join(scenarioRoot, path), "utf8")]];
  });
}
const fixture = await startHttpFixture();
await build({ entryPoints: [resolve(root, "tests/web/index.ts")], outfile: testBundle,
  bundle: true, platform: "browser", format: "cjs", external: ["vscode"], legalComments: "none",
  define: { __FIXTURE__: JSON.stringify({ http: fixture.http, https: fixture.https }),
    __SCENARIOS__: JSON.stringify(Object.fromEntries(scenarioSources())) } });
const output = resolve(root, "test-results/web", new Date().toISOString().replace(/[:.]/g, "-"));
mkdirSync(output, { recursive: true });
function qualified(result) {
  return result.status === 0 && !result.error && !result.signal && /"result":"passed"/.test(result.stdout ?? "");
}
function spawnAsync(command, argumentsList, options) {
  return new Promise((done) => {
    const child = spawn(command, argumentsList, { cwd: options.cwd });
    let stdout = "";
    let stderr = "";
    let failure;
    child.stdout.on("data", (chunk) => { stdout += chunk; });
    child.stderr.on("data", (chunk) => { stderr += chunk; });
    child.on("error", (error) => { failure = error; });
    const timer = setTimeout(() => child.kill("SIGTERM"), options.timeout);
    child.on("close", (status, signal) => { clearTimeout(timer); done({ status, signal, error: failure, stdout, stderr }); });
  });
}
const records = [];
const selected = process.env.PSEUDOLEARN_WEB_BROWSERS?.split(",");
for (const browser of campaign.browsers.filter((name) => !selected || selected.includes(name))) {
  const result = await spawnAsync(process.execPath, [resolve(dirname(runnerPackage), runner.bin["vscode-test-web"]),
    `--browser=${browser}`, `--quality=${campaign.quality}`, `--commit=${campaign.vscodeCommit}`,
    `--extensionDevelopmentPath=${hostStage}`, `--extensionTestsPath=${testBundle}`,
    "--headless", resolve(root, "tests/fixtures/web/project")], { cwd: root, timeout: 300000 });
  writeFileSync(resolve(output, `${browser}.log`), `${result.stdout ?? ""}\n${result.stderr ?? ""}`);
  records.push({ browser, exitCode: result.status, signal: result.signal, error: result.error?.message,
    status: qualified(result) ? "passed" : "not-qualified", logSha256: hash(resolve(output, `${browser}.log`)) });
}
fixture.close();
writeFileSync(resolve(output, "manifest.json"), `${JSON.stringify({ ...campaign, records, provenance: JSON.parse(readFileSync(resolve(root, ".artifacts/web-provenance.json"), "utf8")) }, null, 2)}\n`);
process.stdout.write(`${output}\n`);
if (records.some((record) => record.status !== "passed")) process.exitCode = 1;
