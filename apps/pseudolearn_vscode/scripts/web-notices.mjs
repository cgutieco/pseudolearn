import { readFileSync, readdirSync, writeFileSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { run } from "./lib/run.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const engine = resolve(root, "../../packages/pseudolearn_engine");
const metadata = JSON.parse(run("cargo", ["metadata", "--locked", "--offline", "--format-version=1", "--filter-platform", "wasm32-unknown-unknown"], engine));
const wasm = metadata.packages.find((entry) => entry.name === "pseudolearn_wasm");
const nodes = new Map(metadata.resolve.nodes.map((entry) => [entry.id, entry]));
const used = new Set();
const pending = [wasm.id];
while (pending.length) {
  const id = pending.pop();
  if (used.has(id)) continue;
  used.add(id);
  pending.push(...nodes.get(id).deps.filter((dependency) => dependency.dep_kinds.some((kind) => kind.kind === null))
    .map((dependency) => dependency.pkg));
}
const packages = metadata.packages.filter((entry) => used.has(entry.id) && entry.source)
  .map((entry) => ({ ...entry, directory: dirname(entry.manifest_path) }));
const graph = JSON.parse(readFileSync(resolve(root, ".artifacts/web-metafile.json"), "utf8"));
const javascript = new Map();
for (const path of Object.keys(graph.inputs).filter((path) => path.includes("node_modules/"))) {
  let directory = dirname(resolve(root, path));
  const isPackageRoot = (candidate) => existsSync(resolve(candidate, "package.json"))
    && Boolean(JSON.parse(readFileSync(resolve(candidate, "package.json"), "utf8")).name);
  while (!isPackageRoot(directory) && directory !== dirname(directory)) directory = dirname(directory);
  const manifest = JSON.parse(readFileSync(resolve(directory, "package.json"), "utf8"));
  javascript.set(`${manifest.name}@${manifest.version}`, { ...manifest, directory });
}
packages.push(...javascript.values());
const sections = ["# Avisos de terceros", "", "Dependencias incorporadas en los bundles browser y el módulo Wasm. La licencia propia permanece reservada.", ""];
for (const entry of packages.sort((left, right) => left.name.localeCompare(right.name))) {
  sections.push(`## ${entry.name} ${entry.version}`, "", `Licencia declarada: ${entry.license ?? "no declarada"}.`, "");
  for (const file of readdirSync(entry.directory, { withFileTypes: true }).filter((entry) => entry.isFile() && /^(LICENSE|LICENCE|NOTICE|COPYING)/i.test(entry.name))) {
    sections.push(readFileSync(resolve(entry.directory, file.name), "utf8"), "");
  }
}
writeFileSync(resolve(root, ".artifacts/web-extension/third-party-notices.md"), `${sections.join("\n")}\n`);
