import { readFileSync } from "node:fs";
import { basename, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import ts from "typescript";
import { codeFiles } from "./lib/files.mjs";

const extensionRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

export function findComments(sourceText) {
  const scanner = ts.createScanner(ts.ScriptTarget.Latest, false, ts.LanguageVariant.Standard, sourceText);
  const comments = [];
  let token = scanner.scan();
  while (token !== ts.SyntaxKind.EndOfFileToken) {
    if (token === ts.SyntaxKind.SingleLineCommentTrivia || token === ts.SyntaxKind.MultiLineCommentTrivia) {
      comments.push(scanner.getTokenPos());
    }
    token = scanner.scan();
  }
  return comments;
}

export function collectCommentViolations(root) {
  return codeFiles(root).flatMap((path) => {
    const positions = findComments(readFileSync(path, "utf8"));
    return positions.map((position) => `${path}:${position}: comment is prohibited`);
  });
}

function report(violations) {
  if (violations.length === 0) {
    process.stdout.write("No code comments found.\n");
    return;
  }
  process.stderr.write(`${violations.join("\n")}\n`);
  process.exitCode = 1;
}

if (basename(process.argv[1] ?? "") === basename(fileURLToPath(import.meta.url))) {
  report(collectCommentViolations(extensionRoot));
}
