import {
  type ArchitectureRules,
  findCommentViolations,
  findFileLengthViolations,
  findIdentifierViolations,
  findImportViolations,
  findUndeclaredLayerViolations,
  type SourceFile,
  type Violation,
} from "./architecture_rules.ts";
import { tokenize } from "./source_lexer.ts";

export function checkSourceFile(file: SourceFile, rules: ArchitectureRules): Violation[] {
  return [
    ...findCommentViolations(file, rules),
    ...findFileLengthViolations(file, rules),
    ...findImportViolations(file, rules),
    ...findIdentifierViolations(file, rules),
  ];
}

async function collectTypeScriptFiles(root: string): Promise<string[]> {
  const files: string[] = [];
  for await (const entry of Deno.readDir(root)) {
    const path = `${root}/${entry.name}`;
    if (entry.isDirectory) files.push(...await collectTypeScriptFiles(path));
    if (entry.isFile && entry.name.endsWith(".ts")) files.push(path);
  }
  return files;
}

async function checkFunctionFolders(rules: ArchitectureRules): Promise<Violation[]> {
  const violations: Violation[] = [];
  for await (const functionEntry of Deno.readDir(rules.functions_root)) {
    if (!functionEntry.isDirectory) continue;
    const entries: string[] = [];
    for await (const entry of Deno.readDir(`${rules.functions_root}/${functionEntry.name}`)) {
      entries.push(entry.name);
    }
    violations.push(...findUndeclaredLayerViolations(functionEntry.name, entries, rules));
  }
  return violations;
}

async function checkRepository(): Promise<Violation[]> {
  const rules: ArchitectureRules = JSON.parse(await Deno.readTextFile("architecture.json"));
  const violations = await checkFunctionFolders(rules);
  for (const root of rules.code_rules.scanned_roots) {
    for (const path of await collectTypeScriptFiles(root)) {
      const source = await Deno.readTextFile(path);
      violations.push(...checkSourceFile({ path, source, tokens: tokenize(source) }, rules));
    }
  }
  return violations;
}

if (import.meta.main) {
  const violations = await checkRepository();
  for (const found of violations) {
    console.error(`${found.file}:${found.line} [${found.rule}] ${found.message}`);
  }
  if (violations.length > 0) Deno.exit(1);
  console.log("Architecture checks passed.");
}
