import { build } from "esbuild";
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { graphViolations, hash } from "./lib/web-artifact.mjs";
import { run } from "./lib/run.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const contract = JSON.parse(readFileSync(resolve(root, "artifact.contract.json"), "utf8"));
const stage = resolve(root, ".artifacts/web-extension");
const wasmRoot = resolve(root, "../../packages/pseudolearn_engine/target/wasm-browser/pkg");

function copy(source, destination) {
  if (!existsSync(source)) throw new Error(`Missing build input ${source}; run pnpm build:wasm first`);
  mkdirSync(dirname(destination), { recursive: true });
  copyFileSync(source, destination);
}

function browserManifest() {
  const manifest = JSON.parse(readFileSync(resolve(root, "package.json"), "utf8"));
  delete manifest.main;
  delete manifest.contributes.debuggers;
  delete manifest.contributes.configuration.properties["pseudolearn.server.path"];
  delete manifest.capabilities.untrustedWorkspaces.restrictedConfigurations;
  manifest.browser = `./${contract.web.browser}`;
  manifest.extensionKind = ["workspace"];
  manifest.activationEvents = manifest.activationEvents.filter((event) => !event.startsWith("onDebug"));
  manifest.contributes.commands = manifest.contributes.commands.filter((command) => !command.command.startsWith("pseudolearn.debug"));
  for (const [command, title] of [["grantNetwork", "Grant Network Origin"], ["grantFiles", "Grant Temporary Program Files"], ["showCapabilities", "Show Browser Capabilities"]]) {
    manifest.contributes.commands.push({ command: `pseudolearn.${command}`, title, category: "PseudoLearn" });
  }
  manifest.files = ["README.md", "LICENSE.md", "third-party-notices.md", "package.json", "dist/**", "media/**"];
  manifest.scripts = {};
  delete manifest.dependencies;
  delete manifest.devDependencies;
  return manifest;
}

async function buildBrowser() {
  mkdirSync(stage, { recursive: true });
  for (const file of ["README.md", "LICENSE.md", "media/pseudolearn.tmLanguage.json", "media/language-configuration.json"]) {
    copy(resolve(root, file), resolve(stage, file));
  }
  for (const file of ["pseudolearn_wasm.js", "pseudolearn_wasm_bg.wasm"]) copy(resolve(wasmRoot, file), resolve(stage, "dist/web/wasm", file));
  writeFileSync(resolve(stage, "package.json"), `${JSON.stringify(browserManifest(), null, 2)}\n`);
  const metadata = await bundleEntries();
  writeFileSync(resolve(root, ".artifacts/web-metafile.json"), `${JSON.stringify(metadata, null, 2)}\n`);
  const provenance = { revision: run("git", ["rev-parse", "HEAD"], root).trim(),
    dirty: run("git", ["status", "--porcelain"], root).trim().length > 0,
    node: process.version, rustc: run("rustc", ["--version"], resolve(root, "../../packages/pseudolearn_engine")).trim(),
    files: Object.fromEntries(contract.web.required.filter((path) => path !== "third-party-notices.md").map((path) => [path, hash(resolve(stage, path))])),
    lock: hash(resolve(root, "pnpm-lock.yaml")), inputs: Object.fromEntries(contract.web.externalInputs.map((path) => [path, hash(resolve(root, path))])) };
  writeFileSync(resolve(root, ".artifacts/web-provenance.json"), `${JSON.stringify(provenance, null, 2)}\n`);
  run("node", ["scripts/web-notices.mjs"], root);
  provenance.files["third-party-notices.md"] = hash(resolve(stage, "third-party-notices.md"));
  writeFileSync(resolve(root, ".artifacts/web-provenance.json"), `${JSON.stringify(provenance, null, 2)}\n`);
}

async function bundleEntries() {
  const shared = { absWorkingDir: root, outdir: resolve(stage, "dist/web"), bundle: true, platform: "browser", target: "es2022",
    external: ["vscode"], conditions: ["browser"], define: { process: "undefined" }, metafile: true, legalComments: "none" };
  const extension = await build({ ...shared, entryPoints: ["src/activation/browser_extension.ts"], format: "cjs" });
  const workers = await build({ ...shared, entryPoints: ["src/activation/language_worker.ts", "src/activation/execution_worker.ts"], format: "iife" });
  const metafile = { inputs: { ...extension.metafile.inputs, ...workers.metafile.inputs },
    outputs: { ...extension.metafile.outputs, ...workers.metafile.outputs } };
  const violations = graphViolations(metafile);
  if (violations.length) throw new Error(violations.join("\n"));
  return metafile;
}

await buildBrowser();
