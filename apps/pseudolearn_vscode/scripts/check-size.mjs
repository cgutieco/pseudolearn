import { readFileSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import ts from "typescript";
import { codeFiles } from "./lib/files.mjs";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

export function collectSizeViolations(root) {
  const architecture = JSON.parse(readFileSync(resolve(root, "architecture.json"), "utf8"));
  return codeFiles(root).flatMap((path) => checkFile(path, architecture.size));
}

function checkFile(path, limits) {
  const sourceText = readFileSync(path, "utf8");
  const source = ts.createSourceFile(path, sourceText, ts.ScriptTarget.Latest, true);
  const lines = sourceText.split(/\r?\n/).length;
  const violations = lines > limits.fileLines ? [`${path}: ${lines} lines exceeds ${limits.fileLines}`] : [];
  inspectNode(source, source, { limits, violations }, 0);
  return violations;
}

function inspectNode(node, source, state, nesting) {
  const { limits, violations } = state;
  const nextNesting = nesting + Number(isNestingNode(node));
  if (nextNesting > limits.nestingDepth) {
    violations.push(`${source.fileName}:${node.getStart(source)}: nesting exceeds ${limits.nestingDepth}`);
  }
  if (ts.isFunctionLike(node)) {
    checkFunction(node, source, limits, violations);
  }
  if (ts.isClassLike(node)) {
    checkPublicMethods(node, source, limits, violations);
  }
  ts.forEachChild(node, (child) => inspectNode(child, source, state, nextNesting));
}

function isNestingNode(node) {
  return ts.isIfStatement(node) || ts.isForStatement(node) || ts.isForOfStatement(node)
    || ts.isForInStatement(node) || ts.isWhileStatement(node) || ts.isDoStatement(node)
    || ts.isSwitchStatement(node) || ts.isTryStatement(node);
}

function checkFunction(node, source, limits, violations) {
  if (node.parameters.length > limits.positionalParameters) {
    violations.push(`${source.fileName}:${node.getStart(source)}: parameter count exceeds ${limits.positionalParameters}`);
  }
  if (node.body) {
    const functionLines = source.getLineAndCharacterOfPosition(node.body.end).line
      - source.getLineAndCharacterOfPosition(node.body.getStart(source)).line + 1;
    if (functionLines > limits.functionLines) {
      violations.push(`${source.fileName}:${node.getStart(source)}: function exceeds ${limits.functionLines} lines`);
    }
  }
}

function checkPublicMethods(node, source, limits, violations) {
  const members = node.members.filter((member) => {
    if (!ts.isMethodDeclaration(member) && !ts.isGetAccessorDeclaration(member) && !ts.isSetAccessorDeclaration(member)) {
      return false;
    }
    return !member.modifiers?.some((modifier) => modifier.kind === ts.SyntaxKind.PrivateKeyword
      || modifier.kind === ts.SyntaxKind.ProtectedKeyword);
  });
  if (members.length > limits.publicMethodsPerClass) {
    violations.push(`${source.fileName}:${node.getStart(source)}: public methods exceed ${limits.publicMethodsPerClass}`);
  }
}

function report(violations) {
  if (violations.length === 0) {
    process.stdout.write("Size rules passed.\n");
    return;
  }
  process.stderr.write(`${violations.join("\n")}\n`);
  process.exitCode = 1;
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  report(collectSizeViolations(extensionRoot));
}
