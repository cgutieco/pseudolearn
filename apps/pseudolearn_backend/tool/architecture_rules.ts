import type { SourceToken } from "./source_lexer.ts";

export interface LayerRule {
  readonly name: string;
  readonly path: string;
  readonly may_import: readonly string[];
  readonly forbidden_identifiers: readonly string[];
}

export interface ArchitectureRules {
  readonly functions_root: string;
  readonly layers: readonly LayerRule[];
  readonly forbidden_import_prefixes: readonly string[];
  readonly code_rules: { readonly forbid_comments: boolean; readonly scanned_roots: string[] };
  readonly limits: { readonly file_lines: number };
  readonly limits_exempt: readonly string[];
}

export interface Violation {
  readonly file: string;
  readonly line: number;
  readonly rule: string;
  readonly message: string;
}

export interface SourceFile {
  readonly path: string;
  readonly source: string;
  readonly tokens: readonly SourceToken[];
}

export function findCommentViolations(file: SourceFile, rules: ArchitectureRules): Violation[] {
  if (!rules.code_rules.forbid_comments) return [];
  return file.tokens
    .filter((token) => token.kind === "comment")
    .map((token) => violation(file, token.line, "QUALITY-NO-COMMENTS", "comment found"));
}

export function findFileLengthViolations(file: SourceFile, rules: ArchitectureRules): Violation[] {
  if (rules.limits_exempt.some((prefix) => file.path.startsWith(prefix))) return [];
  const lines = file.source.endsWith("\n")
    ? file.source.split("\n").length - 1
    : file.source.split("\n").length;
  if (lines <= rules.limits.file_lines) return [];
  const message = `file has ${lines} lines (max ${rules.limits.file_lines})`;
  return [violation(file, 1, "SIZE-FILE-LINES", message)];
}

export function layerOf(path: string, rules: ArchitectureRules): LayerRule | null {
  const relative = pathInsideFunction(path, rules);
  if (relative === null) return null;
  return rules.layers.find((layer) =>
    relative === layer.path || relative.startsWith(`${layer.path}/`)
  ) ?? null;
}

export function findImportViolations(file: SourceFile, rules: ArchitectureRules): Violation[] {
  const layer = layerOf(file.path, rules);
  if (layer === null) return [];
  const violations: Violation[] = [];
  for (const { specifier, line } of importSpecifiers(file.tokens)) {
    const problem = importProblem(file.path, specifier, layer, rules);
    if (problem !== null) violations.push(violation(file, line, "LAYER-DIRECTION", problem));
  }
  return violations;
}

export function findIdentifierViolations(file: SourceFile, rules: ArchitectureRules): Violation[] {
  const layer = layerOf(file.path, rules);
  if (layer === null) return [];
  return file.tokens
    .filter((token, index) =>
      token.kind === "identifier" &&
      layer.forbidden_identifiers.includes(token.text) &&
      file.tokens[index - 1]?.text !== "."
    )
    .map((token) =>
      violation(file, token.line, "LAYER-FORBIDDEN-IDENTIFIER", `${layer.name} uses ${token.text}`)
    );
}

export function findUndeclaredLayerViolations(
  functionName: string,
  entries: readonly string[],
  rules: ArchitectureRules,
): Violation[] {
  const declared = new Set(rules.layers.map((layer) => layer.path));
  const location = { path: `${rules.functions_root}/${functionName}`, source: "", tokens: [] };
  const undeclared = entries.filter((entry) => !declared.has(entry))
    .map((entry) => violation(location, 1, "LAYER-DECLARED", `${entry} is not a declared layer`));
  const missing = [...declared].filter((path) => !entries.includes(path))
    .map((path) => violation(location, 1, "LAYER-DECLARED", `declared layer ${path} is missing`));
  return [...undeclared, ...missing];
}

export function importSpecifiers(
  tokens: readonly SourceToken[],
): { specifier: string; line: number }[] {
  const code = tokens.filter((token) => token.kind !== "comment");
  const specifiers: { specifier: string; line: number }[] = [];
  code.forEach((token, index) => {
    const previous = code[index - 1]?.text;
    const beforePrevious = code[index - 2]?.text;
    const isStatic = previous === "from" || (previous === "import" && beforePrevious !== ".");
    const isDynamic = previous === "(" && beforePrevious === "import";
    if (token.kind === "string" && (isStatic || isDynamic)) {
      specifiers.push({ specifier: token.text.slice(1, -1), line: token.line });
    }
  });
  return specifiers;
}

function importProblem(
  importer: string,
  specifier: string,
  layer: LayerRule,
  rules: ArchitectureRules,
): string | null {
  if (rules.forbidden_import_prefixes.some((prefix) => specifier.startsWith(prefix))) {
    return `remote import ${specifier} is forbidden`;
  }
  if (!specifier.startsWith(".")) return `bare import ${specifier} is forbidden`;
  const target = layerOf(resolveRelative(importer, specifier), rules);
  if (target === null) return `${specifier} resolves outside the function layers`;
  if (target.name === layer.name || layer.may_import.includes(target.name)) return null;
  return `${layer.name} may not import ${target.name}`;
}

export function resolveRelative(importer: string, specifier: string): string {
  const segments = importer.split("/").slice(0, -1);
  for (const segment of specifier.split("/")) {
    if (segment === "..") segments.pop();
    else if (segment !== ".") segments.push(segment);
  }
  return segments.join("/");
}

function pathInsideFunction(path: string, rules: ArchitectureRules): string | null {
  const prefix = `${rules.functions_root}/`;
  if (!path.startsWith(prefix)) return null;
  const [, ...rest] = path.slice(prefix.length).split("/");
  return rest.length === 0 ? null : rest.join("/");
}

function violation(file: SourceFile, line: number, rule: string, message: string): Violation {
  return { file: file.path, line, rule, message };
}
