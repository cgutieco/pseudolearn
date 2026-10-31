import { builtinModules } from "node:module";
import { readFileSync, readdirSync } from "node:fs";
import { join, relative } from "node:path";
import { createHash } from "node:crypto";
import ts from "typescript";

export function graphViolations(metadata) {
  const violations = [];
  for (const [path, input] of Object.entries(metadata.inputs ?? {})) {
    if (path.startsWith("../") && path !== "../../packages/pseudolearn_engine/crates/pseudolearn_wasm/browser/fetch_host.mjs") {
      violations.push(`${path}: undeclared external build input`);
    }
    for (const imported of input.imports ?? []) {
      if (imported.path.startsWith("node:") || builtinModules.includes(imported.path)
        || imported.path.includes("vscode-languageclient/lib/node/")
        || imported.external && imported.path !== "vscode") {
        violations.push(`${path}: forbidden browser import ${imported.path}`);
      }
    }
  }
  return violations;
}

export function globalViolations(source) {
  const violations = [];
  const tree = ts.createSourceFile("browser.js", source, ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
  function visit(node) {
    const isMemberName = node.parent && ((ts.isPropertyAccessExpression(node.parent) && node.parent.name === node)
      || (ts.isPropertyAssignment(node.parent) && node.parent.name === node));
    if (ts.isIdentifier(node) && !isMemberName && ["process", "Buffer", "global"].includes(node.text)) violations.push(`Forbidden browser global ${node.text}`);
    ts.forEachChild(node, visit);
  }
  visit(tree);
  return violations;
}

export function inventoryViolations(actual, required) {
  return [...required.filter((path) => !actual.includes(path)).map((path) => `Missing ${path}`),
    ...actual.filter((path) => !required.includes(path)).map((path) => `Unexpected ${path}`)];
}

export function walk(root, directory = root) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walk(root, path) : [relative(root, path).split("\\").join("/")];
  });
}

export function hash(path) {
  return createHash("sha256").update(readFileSync(path)).digest("hex");
}

export function memoryMaximum(bytes) {
  let offset = 8;
  const number = () => {
    let value = 0;
    let shift = 0;
    let byte;
    do {
      if (offset >= bytes.length || shift > 28) throw new Error("Invalid Wasm integer");
      byte = bytes[offset++];
      value += (byte & 127) * 2 ** shift;
      shift += 7;
    } while (byte & 128);
    return value;
  };
  while (offset < bytes.length) {
    const section = bytes[offset++];
    const length = number();
    const end = offset + length;
    if (section === 5) {
      if (number() !== 1 || number() !== 1) throw new Error("Expected one private bounded Wasm memory");
      number();
      return number();
    }
    offset = end;
  }
  throw new Error("Wasm memory section is missing");
}
