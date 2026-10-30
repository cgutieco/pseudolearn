import { chmodSync, copyFileSync, existsSync, mkdirSync, statSync, writeFileSync } from "node:fs";
import { basename, dirname, isAbsolute, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { loadContract, sha256File } from "./lib/artifact.mjs";
import { run } from "./lib/run.mjs";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const cliRoot = resolve(extensionRoot, "../../apps/pseudolearn_cli");

export function provenancePath(root) {
  return resolve(root, ".artifacts/provenance.json");
}

export function buildCli(root = extensionRoot) {
  const contract = loadContract(root);
  const binaryPath = resolve(root, contract.executable);
  mkdirSync(dirname(binaryPath), { recursive: true });
  const origin = copyBinary(contract, binaryPath);
  chmodSync(binaryPath, 0o755);
  const repository = resolve(root, "../..");
  const provenance = {
    revision: run("git", ["rev-parse", "HEAD"], repository).trim(),
    dirty: run("git", ["status", "--porcelain"], repository).trim().length > 0,
    rustc: run("rustc", ["--version"], cliRoot).trim(),
    cargo: run("cargo", ["--version"], cliRoot).trim(),
    node: process.version,
    cargoTarget: contract.target.cargoTarget,
    origin,
    binarySha256: sha256File(binaryPath),
    grammarSha256: sha256File(resolve(root, contract.grammar)),
  };
  mkdirSync(dirname(provenancePath(root)), { recursive: true });
  writeFileSync(provenancePath(root), `${JSON.stringify(provenance, null, 2)}\n`);
  return provenance;
}

function copyBinary(contract, binaryPath) {
  const override = process.env.PSEUDOLEARN_PSEUDO_PATH;
  if (override) {
    if (process.env.NODE_ENV !== "development" || !isAbsolute(override)) {
      throw new Error("The pseudo override requires NODE_ENV=development and an absolute path.");
    }
    if (!existsSync(override) || !statSync(override).isFile()) throw new Error("The pseudo override must name a file.");
    copyFileSync(override, binaryPath);
    return "development-override";
  }
  run("cargo", ["build", "--locked", "--release", "--target", contract.target.cargoTarget], cliRoot);
  copyFileSync(resolve(cliRoot, `target/${contract.target.cargoTarget}/release/pseudo`), binaryPath);
  return "cargo-release-locked";
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  try {
    process.stdout.write(`${JSON.stringify(buildCli())}\n`);
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exitCode = 1;
  }
}
