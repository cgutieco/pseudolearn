import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { hash, inventoryViolations } from "./lib/web-artifact.mjs";
import { run } from "./lib/run.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const stage = resolve(root, ".artifacts/web-extension");
const contract = JSON.parse(readFileSync(resolve(root, "artifact.contract.json"), "utf8")).web;
run("node", ["scripts/check-web.mjs"], root);
const artifact = resolve(root, ".artifacts", contract.artifactName);
run(resolve(root, "node_modules/.bin/vsce"), ["package", "--target", "web", "--no-dependencies", "--out", artifact], stage);
const listing = run("unzip", ["-Z1", artifact], root).trim().split(/\r?\n/)
  .filter((path) => path.startsWith("extension/")).map((path) => path.slice(10));
const required = contract.required.map((path) => path === "README.md" ? "readme.md" : path);
const violations = inventoryViolations(listing, required);
const manifest = run("unzip", ["-p", artifact, "extension.vsixmanifest"], root);
if (!manifest.includes('TargetPlatform="web"')) violations.push("VSIX target must be web");
if (violations.length) throw new Error(violations.join("\n"));
const provenance = JSON.parse(readFileSync(resolve(root, ".artifacts/web-provenance.json"), "utf8"));
const record = { ...provenance, artifact, bytes: readFileSync(artifact).length, sha256: hash(artifact), target: "web" };
writeFileSync(`${artifact}.json`, `${JSON.stringify(record, null, 2)}\n`);
writeFileSync(`${artifact}.sha256`, `${record.sha256}  ${contract.artifactName}\n`);
process.stdout.write(`${artifact}\n`);
