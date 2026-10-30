import { chmodSync, copyFileSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { basename, dirname, isAbsolute, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const cliRoot = resolve(extensionRoot, "../../apps/pseudolearn_cli");
const targetDirectory = resolve(extensionRoot, "bin/darwin-arm64");
const outputDirectory = resolve(extensionRoot, ".artifacts");
const binaryPath = resolve(targetDirectory, "pseudo");
const artifactPath = resolve(outputDirectory, "pseudolearn-0.1.0-darwin-arm64.vsix");

export function packageLocalExtension() {
  if (process.platform !== "darwin" || process.arch !== "arm64") {
    throw new Error("The qualified VSIX target requires a darwin-arm64 host.");
  }
  mkdirSync(targetDirectory, { recursive: true });
  packageBinary();
  writeThirdPartyNotices();
  mkdirSync(outputDirectory, { recursive: true });
  run("pnpm", ["exec", "vsce", "package", "--target", "darwin-arm64", "--no-dependencies", "--out", artifactPath]);
  inspectArtifact(artifactPath);
  return artifactPath;
}

function packageBinary() {
  const override = process.env.PSEUDOLEARN_PSEUDO_PATH;
  if (override) {
    if (process.env.NODE_ENV !== "development" || !isAbsolute(override)) {
      throw new Error("The pseudo override requires NODE_ENV=development and an absolute path.");
    }
    if (!statSync(override).isFile()) throw new Error("The pseudo override must name a file.");
    copyFileSync(override, binaryPath);
  } else {
    run("cargo", ["build", "--locked", "--release", "--target", "aarch64-apple-darwin"], cliRoot);
    copyFileSync(resolve(cliRoot, "target/aarch64-apple-darwin/release/pseudo"), binaryPath);
  }
  chmodSync(binaryPath, 0o755);
}

function inspectArtifact(path) {
  const listing = run("unzip", ["-Z1", path]).split(/\r?\n/).filter(Boolean);
  const packaged = listing.filter((entry) => entry.startsWith("extension/")).map((entry) => entry.slice("extension/".length));
  const required = ["package.json", "readme.md", "LICENSE.md", "third-party-notices.md", "dist/extension.js", "bin/darwin-arm64/pseudo"];
  for (const name of required) {
    if (!packaged.includes(name)) throw new Error(`VSIX is missing ${name}.`);
  }
  for (const name of packaged) {
    if (isForbidden(name)) throw new Error(`VSIX contains forbidden resource ${name}.`);
  }
}

function writeThirdPartyNotices() {
  const packages = loadCliDependencyPackages();
  const licenseTexts = collectLicenseTexts(packages);
  const content = renderThirdPartyNotices(packages, licenseTexts);
  writeFileSync(join(extensionRoot, "third-party-notices.md"), content);
}

function loadCliDependencyPackages() {
  const metadata = JSON.parse(run("cargo", [
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

function isForbidden(path) {
  const parts = path.split("/");
  return parts.some((part) => ["src", "tests", "scripts", "node_modules", ".git"].includes(part))
    || basename(path).startsWith(".env") || path.endsWith(".map");
}

function run(command, argumentsList, cwd = extensionRoot) {
  const result = spawnSync(command, argumentsList, { cwd, encoding: "utf8", maxBuffer: 16 * 1024 * 1024, stdio: "pipe" });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(result.stderr || `${command} exited with status ${result.status}`);
  return result.stdout;
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  try {
    process.stdout.write(`${packageLocalExtension()}\n`);
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exitCode = 1;
  }
}
