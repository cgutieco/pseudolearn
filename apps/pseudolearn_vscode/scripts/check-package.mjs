import { existsSync, readFileSync, readdirSync } from "node:fs";
import { basename, dirname, extname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

export function collectPackageViolations(root) {
  const architecture = readJson(resolve(root, "architecture.json"));
  const manifest = readJson(resolve(root, "package.json"));
  const violations = [];
  if (JSON.stringify(manifest.files) !== JSON.stringify(architecture.package.included)) {
    violations.push("package files do not match the declared package inclusion list");
  }
  if (!manifest.private || manifest.publisher !== "pseudolearn" || manifest.version !== "0.1.0") {
    violations.push("extension identity or local-only publication settings are invalid");
  }
  if (manifest.engines?.node !== "22.23.3" || manifest.packageManager !== "pnpm@12.8.1") {
    violations.push("runtime toolchain versions do not match the declared release");
  }
  if (manifest.engines?.vscode !== "^1.144.0" || !manifest.license?.includes("LICENSE.md")) {
    violations.push("editor floor or reserved-rights license metadata is invalid");
  }
  for (const path of includedFiles(root, architecture.package.included)) {
    const name = relative(root, path).split("/").join("/");
    if (isExcluded(name, architecture.package.excluded)) {
      violations.push(`${name}: excluded resource is included`);
    }
    if (extname(name) === ".env" || basename(name).startsWith(".env")) {
      violations.push(`${name}: environment secrets are excluded`);
    }
    if (hasSecretKey(readJsonIfJson(path, name))) {
      violations.push(`${name}: secret-bearing package resource is excluded`);
    }
  }
  return violations;
}

function includedFiles(root, patterns) {
  return walk(root).filter((path) => patterns.some((pattern) => matches(relative(root, path), pattern)));
}

function walk(directory) {
  if (!existsSync(directory)) return [];
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walk(path) : [path];
  });
}

function matches(path, pattern) {
  const normalized = path.split("\\").join("/");
  if (pattern.endsWith("/**")) return normalized.startsWith(pattern.slice(0, -2));
  return normalized === pattern;
}

function isExcluded(path, patterns) {
  return patterns.some((pattern) => matches(path, pattern) || pattern.endsWith("/**") && path.startsWith(pattern.slice(0, -2)));
}

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

function readJsonIfJson(path, name) {
  return name.endsWith(".json") ? readJson(path) : undefined;
}

function hasSecretKey(value) {
  if (!value || typeof value !== "object") return false;
  return Object.entries(value).some(([key, item]) => {
    const normalized = key.toLowerCase();
    return ["api_key", "password", "secret", "token"].includes(normalized) || hasSecretKey(item);
  });
}

function report(violations) {
  if (violations.length === 0) {
    process.stdout.write("Package rules passed.\n");
    return;
  }
  process.stderr.write(`${violations.join("\n")}\n`);
  process.exitCode = 1;
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  report(collectPackageViolations(extensionRoot));
}
