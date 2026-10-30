import { existsSync, readFileSync, readdirSync } from "node:fs";
import { basename, dirname, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import ts from "typescript";
import { codeFiles } from "./lib/files.mjs";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

export function collectArchitectureViolations(root) {
  const architecture = JSON.parse(readFileSync(resolve(root, "architecture.json"), "utf8"));
  const layers = Object.entries(architecture.layers);
  const violations = [];
  const sourceRoot = resolve(root, "src");
  const context = { root, sourceRoot, architecture, layers, violations };
  validateDirectories(context);
  validateImports(context);
  return violations;
}

function validateDirectories(context) {
  const { root, sourceRoot, architecture, layers, violations } = context;
  for (const [, layer] of layers) {
    if (!existsSync(resolve(sourceRoot, layer.directory.slice("src/".length)))) {
      violations.push(`${layer.directory}: declared layer directory is missing`);
    }
  }
  for (const entry of readdirSync(sourceRoot, { withFileTypes: true })) {
    if (!entry.isDirectory() || !layers.some(([, layer]) => layer.directory === `src/${entry.name}`)) {
      violations.push(`src/${entry.name}: source entry is not a declared layer`);
    }
  }
  for (const forbidden of architecture.forbiddenDirectories) {
    if (existsSync(resolve(root, forbidden))) {
      violations.push(`${forbidden}: forbidden directory exists`);
    }
  }
}

function validateImports(context) {
  const { root, sourceRoot, architecture, layers, violations } = context;
  for (const path of codeFiles(sourceRoot)) {
    const sourceLayer = layerForPath(root, path, layers);
    if (!sourceLayer) {
      violations.push(`${relative(root, path)}: source file has no declared layer`);
      continue;
    }
    const sourceText = readFileSync(path, "utf8");
    const source = ts.createSourceFile(path, sourceText, ts.ScriptTarget.Latest, true);
    for (const specifier of importSpecifiers(source)) {
      const targetLayer = specifier.startsWith(".")
        ? layerForPath(root, resolve(dirname(path), specifier), layers)
        : undefined;
      if (targetLayer && !architecture.layers[sourceLayer].imports.includes(targetLayer)) {
        violations.push(`${relative(root, path)}: ${sourceLayer} cannot import ${targetLayer}`);
      }
      if (isHostImport(specifier) && !["adapters", "activation"].includes(sourceLayer)) {
        violations.push(`${relative(root, path)}: ${sourceLayer} cannot import ${specifier}`);
      }
    }
  }
}

function importSpecifiers(source) {
  const specifiers = [];
  function visit(node) {
    if ((ts.isImportDeclaration(node) || ts.isExportDeclaration(node)) && node.moduleSpecifier) {
      if (ts.isStringLiteral(node.moduleSpecifier)) {
        specifiers.push(node.moduleSpecifier.text);
      }
    }
    ts.forEachChild(node, visit);
  }
  visit(source);
  return specifiers;
}

function layerForPath(root, path, layers) {
  const normalizedPath = relative(root, path).split(sep).join("/");
  return layers.find(([, layer]) => normalizedPath.startsWith(`${layer.directory}/`))?.[0];
}

function isHostImport(specifier) {
  return specifier === "vscode" || specifier.startsWith("node:") || specifier === "vscode-languageclient";
}

function report(violations) {
  if (violations.length === 0) {
    process.stdout.write("Architecture rules passed.\n");
    return;
  }
  process.stderr.write(`${violations.join("\n")}\n`);
  process.exitCode = 1;
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  report(collectArchitectureViolations(extensionRoot));
}
