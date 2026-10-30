import { mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { basename, dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createHash } from "node:crypto";
import { provenancePath } from "./build-cli.mjs";
import {
  bundleViolations,
  listingViolations,
  loadContract,
  manifestViolations,
  provenanceViolations,
  sha256File,
  vsixManifestViolations,
} from "./lib/artifact.mjs";
import { run as runCommand } from "./lib/run.mjs";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const cliRoot = resolve(extensionRoot, "../../apps/pseudolearn_cli");
const outputDirectory = resolve(extensionRoot, ".artifacts");

export function packageLocalExtension(root = extensionRoot) {
  const contract = loadContract(root);
  assertQualifiedTarget(process.platform, process.arch);
  assertProvenance(root, contract);
  runCommand("node", ["scripts/generate-grammar.mjs", "--check"], root);
  writeThirdPartyNotices();
  mkdirSync(outputDirectory, { recursive: true });
  const artifactPath = resolve(outputDirectory, contract.artifactName);
  runCommand("pnpm", ["exec", "vsce", "package", "--target", contract.target.vscodeTarget, "--no-dependencies", "--out", artifactPath], root);
  inspectArtifact(artifactPath, root, contract);
  writeArtifactRecord(artifactPath, root, contract);
  return artifactPath;
}

export function assertQualifiedTarget(platform, architecture) {
  if (platform !== "darwin" || architecture !== "arm64") {
    throw new Error("The qualified VSIX target requires a darwin-arm64 host.");
  }
}

function assertProvenance(root, contract) {
  let provenance;
  try {
    provenance = JSON.parse(readFileSync(provenancePath(root), "utf8"));
  } catch {
    provenance = undefined;
  }
  const actual = { binary: safeHash(resolve(root, contract.executable)), grammar: safeHash(resolve(root, contract.grammar)) };
  const violations = provenanceViolations(provenance, actual, contract);
  if (violations.length > 0) throw new Error(violations.join("\n"));
}

function safeHash(path) {
  try {
    return sha256File(path);
  } catch {
    return undefined;
  }
}

function inspectArtifact(path, root, contract) {
  const listing = runCommand("unzip", ["-Z1", path], root).split(/\r?\n/).filter(Boolean);
  const vsixManifest = runCommand("unzip", ["-p", path, "extension.vsixmanifest"], root);
  const bundle = readFileSync(resolve(root, contract.bundle), "utf8");
  const manifest = JSON.parse(readFileSync(resolve(root, "package.json"), "utf8"));
  const violations = [
    ...listingViolations(listing, contract),
    ...vsixManifestViolations(vsixManifest, contract),
    ...bundleViolations(bundle, contract),
    ...manifestViolations(manifest, contract),
  ];
  if (violations.length > 0) throw new Error(violations.join("\n"));
}

function writeArtifactRecord(path, root, contract) {
  const provenance = JSON.parse(readFileSync(provenancePath(root), "utf8"));
  const record = {
    name: contract.artifactName,
    path,
    bytes: readFileSync(path).length,
    sha256: sha256File(path),
    binarySha256: provenance.binarySha256,
    grammarSha256: provenance.grammarSha256,
    bundleSha256: sha256File(resolve(root, contract.bundle)),
    vscodeTarget: contract.target.vscodeTarget,
    revision: provenance.revision,
    dirty: provenance.dirty,
    rustc: provenance.rustc,
    cargo: provenance.cargo,
    node: provenance.node,
  };
  writeFileSync(`${path}.json`, `${JSON.stringify(record, null, 2)}\n`);
  writeFileSync(`${path}.sha256`, `${record.sha256}  ${contract.artifactName}\n`);
}

function writeThirdPartyNotices() {
  const packages = loadCliDependencyPackages();
  const licenseTexts = collectLicenseTexts(packages);
  const content = renderThirdPartyNotices(packages, licenseTexts);
  writeFileSync(join(extensionRoot, "third-party-notices.md"), content);
}

function loadCliDependencyPackages() {
  const metadata = JSON.parse(runCommand("cargo", [
    "metadata",
    "--locked",
    "--format-version=1",
    "--filter-platform",
    "aarch64-apple-darwin",
    "--manifest-path",
    join(cliRoot, "Cargo.toml"),
  ], cliRoot));
  return dependencyPackages(metadata, "pseudolearn_cli");
}

function collectLicenseTexts(packages) {
  const licenseTexts = new Map();
  for (const packageInfo of packages) {
    for (const licenseFile of packageLicenseFiles(packageInfo)) {
      const text = readFileSync(licenseFile);
      const hash = createHash("sha256").update(text).digest("hex");
      const entry = licenseTexts.get(hash) ?? { names: new Set(), text: text.toString("utf8") };
      entry.names.add(basename(licenseFile));
      licenseTexts.set(hash, entry);
    }
  }
  if (licenseTexts.size === 0) throw new Error("No third-party license texts were found for the CLI binary.");
  return licenseTexts;
}

function renderThirdPartyNotices(packages, licenseTexts) {
  const packageRows = packages.map((packageInfo) => `| ${packageInfo.name} | ${packageInfo.version} | ${packageInfo.license} |`);
  const licenseSections = [...licenseTexts.values()].map((entry, index) =>
    `## Texto ${index + 1}: ${[...entry.names].sort().join(", ")}\n\n${entry.text.trimEnd()}`,
  );
  const content = [
    "# Avisos de terceros",
    "",
    "El binario `pseudo` incluye dependencias de Cargo para `aarch64-apple-darwin`. Se enumeran los paquetes resueltos y se conservan los textos de licencia disponibles en sus fuentes. Las licencias SPDX se registran tal como las declaran los paquetes.",
    "",
    "| Paquete | Versión | Licencia SPDX |",
    "| --- | --- | --- |",
    ...packageRows,
    "",
    "## Textos de licencia y avisos",
    "",
    ...licenseSections,
    "",
  ].join("\n");
  return content;
}

function dependencyPackages(metadata, rootName) {
  const root = metadata.packages.find((packageInfo) => packageInfo.name === rootName);
  if (!root || !metadata.resolve) throw new Error(`Cargo metadata is missing ${rootName}.`);
  const nodes = new Map(metadata.resolve.nodes.map((node) => [node.id, node]));
  const packagesById = new Map(metadata.packages.map((packageInfo) => [packageInfo.id, packageInfo]));
  const visited = new Set();
  const pending = [root.id];
  while (pending.length > 0) {
    const identifier = pending.pop();
    if (visited.has(identifier)) continue;
    visited.add(identifier);
    const node = nodes.get(identifier);
    if (!node) throw new Error(`Cargo metadata is missing node ${identifier}.`);
    pending.push(...node.deps.map((dependency) => dependency.pkg));
  }
  return [...visited]
    .map((identifier) => packagesById.get(identifier))
    .filter((packageInfo) => packageInfo?.source)
    .sort((left, right) => left.name.localeCompare(right.name) || left.version.localeCompare(right.version));
}

function packageLicenseFiles(packageInfo) {
  const packageDirectory = dirname(packageInfo.manifest_path);
  const files = readdirSync(packageDirectory, { withFileTypes: true })
    .filter((entry) => entry.isFile() && /^(LICENSE|LICENCE|COPYING|NOTICE|COPYRIGHT)/i.test(entry.name))
    .map((entry) => join(packageDirectory, entry.name));
  if (packageInfo.license_file) files.push(resolve(packageDirectory, packageInfo.license_file));
  return [...new Set(files)].sort();
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  try {
    process.stdout.write(`${packageLocalExtension()}\n`);
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exitCode = 1;
  }
}
