import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { brotliCompressSync, constants } from "node:zlib";
import { globalViolations, graphViolations, hash, inventoryViolations, memoryMaximum, walk } from "./lib/web-artifact.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const stage = resolve(root, ".artifacts/web-extension");
const contract = JSON.parse(readFileSync(resolve(root, "artifact.contract.json"), "utf8")).web;
const metadata = JSON.parse(readFileSync(resolve(root, ".artifacts/web-metafile.json"), "utf8"));
const provenance = JSON.parse(readFileSync(resolve(root, ".artifacts/web-provenance.json"), "utf8"));
const violations = [...graphViolations(metadata), ...inventoryViolations(walk(stage), contract.required)];
for (const path of [contract.browser, ...contract.workers, contract.glue]) violations.push(...globalViolations(readFileSync(resolve(stage, path), "utf8")));
for (const [path, expected] of Object.entries(provenance.files)) {
  if (hash(resolve(stage, path)) !== expected) violations.push(`Hash mismatch: ${path}`);
}
for (const [path, expected] of Object.entries(provenance.inputs)) {
  if (hash(resolve(root, path)) !== expected) violations.push(`Input changed: ${path}`);
}
if (hash(resolve(root, "pnpm-lock.yaml")) !== provenance.lock) violations.push("Lockfile changed after build");
const manifest = JSON.parse(readFileSync(resolve(stage, "package.json"), "utf8"));
if (manifest.main || manifest.browser !== `./${contract.browser}` || manifest.contributes.debuggers) violations.push("Invalid browser manifest");
const wasm = readFileSync(resolve(stage, contract.wasm));
const compressed = brotliCompressSync(wasm, { params: { [constants.BROTLI_PARAM_QUALITY]: 11, [constants.BROTLI_PARAM_LGWIN]: 22 } });
if (compressed.length > contract.maximumWasmBrotliBytes) violations.push(`Wasm Brotli ${compressed.length} exceeds ${contract.maximumWasmBrotliBytes}`);
if (memoryMaximum(wasm) !== contract.maximumMemoryPages) violations.push("Wasm memory maximum differs from contract");
if (violations.length) throw new Error(violations.join("\n"));
process.stdout.write(`${JSON.stringify({ wasmBytes: wasm.length, wasmBrotliBytes: compressed.length, maximumMemoryPages: memoryMaximum(wasm), files: walk(stage).length })}\n`);
