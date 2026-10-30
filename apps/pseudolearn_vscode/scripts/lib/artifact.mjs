import { builtinModules } from "node:module";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { basename } from "node:path";

export function loadContract(root) {
  return JSON.parse(readFileSync(`${root}/artifact.contract.json`, "utf8"));
}

export function sha256(content) {
  return createHash("sha256").update(content).digest("hex");
}

export function sha256File(path) {
  return sha256(readFileSync(path));
}

export function packagedEntries(listing) {
  return listing.filter((entry) => entry.startsWith("extension/")).map((entry) => entry.slice("extension/".length));
}

export function listingViolations(listing, contract) {
  const entries = packagedEntries(listing);
  const violations = contract.required
    .filter((name) => !entries.includes(name))
    .map((name) => `VSIX is missing ${name}`);
  for (const name of entries) {
    if (isForbidden(name, contract)) violations.push(`VSIX contains forbidden resource ${name}`);
    else if (!isDeclared(name, contract)) violations.push(`VSIX contains undeclared resource ${name}`);
  }
  return violations;
}

function isForbidden(name, contract) {
  const segments = name.split("/");
  return segments.some((segment) => contract.forbiddenSegments.includes(segment))
    || contract.forbiddenSuffixes.some((suffix) => name.endsWith(suffix))
    || contract.forbiddenPrefixes.some((prefix) => basename(name).startsWith(prefix));
}

function isDeclared(name, contract) {
  return contract.allowedFiles.includes(name) || contract.allowedPrefixes.some((prefix) => name.startsWith(prefix));
}

export function bundleViolations(bundleText, contract) {
  const allowed = new Set([...contract.externalRuntimeModules, ...builtinModules]);
  const violations = [];
  for (const match of bundleText.matchAll(/require\("([^"]+)"\)/g)) {
    const name = match[1].replace(/^node:/, "").split("/")[0];
    if (!allowed.has(name) && !allowed.has(match[1])) violations.push(`bundle requires ${match[1]} at runtime but does not contain it`);
  }
  for (const name of contract.bundledRuntimeModules) {
    if (!bundleText.includes(name)) violations.push(`bundle does not contain runtime dependency ${name}`);
  }
  return violations;
}

export function manifestViolations(manifest, contract) {
  const violations = [];
  const { identity, engines } = contract;
  if (manifest.publisher !== identity.publisher || manifest.name !== identity.name || manifest.version !== identity.version) {
    violations.push("extension identity or version differs from the artifact contract");
  }
  if (manifest.engines?.vscode !== engines.vscode) violations.push("minimum VS Code differs from the artifact contract");
  return violations;
}

export function vsixManifestViolations(text, contract) {
  const violations = [];
  if (!text.includes(`TargetPlatform="${contract.target.vscodeTarget}"`)) {
    violations.push(`VSIX target platform is not ${contract.target.vscodeTarget}`);
  }
  if (!text.includes(`Version="${contract.identity.version}"`)) violations.push("VSIX version differs from the artifact contract");
  return violations;
}

export function provenanceViolations(provenance, actual, contract) {
  if (!provenance) return ["binary has no provenance record"];
  const violations = [];
  for (const field of ["revision", "rustc", "cargo", "node"]) {
    if (!provenance[field]) violations.push(`provenance is missing ${field}`);
  }
  if (provenance.cargoTarget !== contract.target.cargoTarget) violations.push("provenance target differs from the artifact contract");
  if (!actual.binary) violations.push("packaged binary is missing");
  else if (provenance.binarySha256 !== actual.binary) violations.push("packaged binary differs from the recorded build");
  if (provenance.grammarSha256 !== actual.grammar) violations.push("grammar changed after the binary was built and must be regenerated");
  return violations;
}

export function hashViolations(record, actual) {
  return Object.entries(record)
    .filter(([name, hash]) => actual[name] !== hash)
    .map(([name]) => `hash of ${name} differs from the recorded artifact`);
}
