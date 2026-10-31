import { createServer } from "node:http";
import { build as bundle } from "esbuild";
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import { hash } from "./lib/web-artifact.mjs";
import { summarize } from "./lib/web-measurements.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const stage = resolve(root, ".artifacts/web-extension");
const script = fileURLToPath(import.meta.url);
const workloads = [
  { name: "integer-extreme", source: "Algoritmo Probe\nEscribir 9223372036854775807;\nFinAlgoritmo\n", expected: "9223372036854775807\n" },
  { name: "loop", source: "Algoritmo Probe\nDefinir Mutable total Como Entero <- 0;\nMientras total < 1000 Hacer\ntotal <- total + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n", expected: "1000\n" },
  { name: "cancellation", source: "Algoritmo Probe\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n", expected: "", cancel: true },
];

async function serve() {
  const server = createServer((request, response) => {
    if (request.url === "/benchmark.js") { response.setHeader("Content-Type", "text/javascript"); response.end(readFileSync(resolve(root, ".artifacts/benchmark.js"))); return; }
    if (request.url === "/") { response.end("<!doctype html><title>PseudoLearn measurement control</title>"); return; }
    const requestPath = decodeURIComponent(new URL(request.url, "http:" + "//localhost").pathname);
    const path = resolve(stage, `.${requestPath}`);
    if (!path.startsWith(`${stage}${sep}`) || !existsSync(path)) { response.writeHead(404).end(); return; }
    response.setHeader("Cache-Control", "no-store");
    response.setHeader("Content-Type", path.endsWith(".wasm") ? "application/wasm" : "text/javascript");
    response.end(readFileSync(path));
  });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  return { server, url: "http:" + "//127.0.0.1:" + server.address().port };
}

async function sample(page, options) {
  let timer;
  try {
    return await Promise.race([page.evaluate((options) => globalThis.pseudolearnBenchmark(options), options),
      new Promise((_resolve, reject) => { timer = setTimeout(() => reject(new Error("Measurement timed out")), 30000); })]);
  } finally { clearTimeout(timer); }
}

async function measureIteration(page, processNumber, iteration) {
  const rows = [];
  for (const workload of workloads) {
    const targets = (iteration + processNumber) % 2 ? ["worker", "control"] : ["control", "worker"];
    for (const target of targets) rows.push(await attempt(page, { processNumber, iteration, target, workload }));
  }
  return rows;
}

async function attempt(page, { processNumber, iteration, target, workload }) {
  try { return { process: processNumber, iteration, target, workload: workload.name, expected: workload.expected,
    unit: "ms", ...(await sample(page, { target, workload, iteration })) }; }
  catch (error) { return { process: processNumber, iteration, target, workload: workload.name, valid: false, error: String(error) }; }
}

async function child(processNumber) {
  const require = createRequire(resolve(root, "../../packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/package.json"));
  const { chromium } = require("playwright-core");
  const { server, url } = await serve();
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.goto(url);
  await page.addScriptTag({ url: `${url}/benchmark.js` });
  const rows = [];
  try {
    for (let iteration = 0; iteration < 30; iteration += 1) {
      rows.push(...await measureIteration(page, processNumber, iteration));
    }
  } finally { await browser.close(); await new Promise((resolve) => server.close(resolve)); }
  process.stdout.write(`${JSON.stringify({ browser: browser.version(), rows })}\n`);
}

async function campaign() {
  await bundle({ entryPoints: [resolve(root, "tests/web/benchmark_page.ts")], outfile: resolve(root, ".artifacts/benchmark.js"), bundle: true, platform: "browser", format: "iife", legalComments: "none" });
  const output = resolve(root, "test-results/web-bench", new Date().toISOString().replace(/[:.]/g, "-"));
  mkdirSync(output, { recursive: true });
  const build = hash(resolve(stage, "dist/web/wasm/pseudolearn_wasm_bg.wasm"));
  const rows = [];
  for (let processNumber = 0; processNumber < 10; processNumber += 1) {
    const result = spawnSync(process.execPath, [script, "--process", String(processNumber)], { cwd: root, encoding: "utf8", timeout: 1800000 });
    writeFileSync(resolve(output, `process-${processNumber}.json`), result.stdout || "null\n");
    writeFileSync(resolve(output, `process-${processNumber}.stderr`), result.stderr ?? "");
    if (result.status === 0) rows.push(...JSON.parse(result.stdout).rows.map((row) => ({ ...row, build })));
    else rows.push({ process: processNumber, valid: false, error: result.error?.message ?? `exit ${result.status}`, build });
  }
  writeFileSync(resolve(output, "attempts.json"), `${JSON.stringify(rows, null, 2)}\n`);
  const summary = { target: "wasm-worker-control", physical: false, vscodeHost: false, seed: 42,
    preparation: "Fresh Wasm instance per attempt; fresh browser and Node process per process group", results: summarize(rows) };
  writeFileSync(resolve(output, "summary.json"), `${JSON.stringify(summary, null, 2)}\n`);
  process.stdout.write(`${output}\n`);
}

if (process.argv[2] === "--process") await child(Number(process.argv[3]));
else await campaign();
