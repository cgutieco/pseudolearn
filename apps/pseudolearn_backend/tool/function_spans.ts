import type { SourceToken } from "./source_lexer.ts";

export interface FunctionSpan {
  readonly name: string;
  readonly startLine: number;
  readonly endLine: number;
}

const controlKeywords = new Set(["if", "for", "while", "switch", "catch", "with", "return"]);
const openers = new Set(["(", "[", "{"]);
const closers = new Set([")", "]", "}"]);

export function functionSpans(tokens: readonly SourceToken[]): FunctionSpan[] {
  const code = tokens.filter((token) => token.kind !== "comment");
  const spans: FunctionSpan[] = [];
  code.forEach((_token, index) => {
    const body = bodyOpening(code, index);
    if (body === null) return;
    const close = matchingClose(code, body);
    if (close === null) return;
    const head = headOf(code, index);
    spans.push({ name: head.name, startLine: head.line, endLine: code[close].line });
  });
  return spans;
}

function bodyOpening(code: readonly SourceToken[], index: number): number | null {
  const token = code[index];
  if (isArrow(code, index) && code[index + 2]?.text === "{") return index + 2;
  if (token.kind !== "identifier" || controlKeywords.has(token.text)) return null;
  if (code[index + 1]?.text !== "(") return null;
  const close = matchingClose(code, index + 1);
  if (close === null) return null;
  return bodyAfterSignature(code, close + 1);
}

function bodyAfterSignature(code: readonly SourceToken[], from: number): number | null {
  if (code[from]?.text === "{") return from;
  if (code[from]?.text !== ":") return null;
  let depth = 0;
  for (let cursor = from + 1; cursor < code.length; cursor++) {
    const text = code[cursor].text;
    if (depth === 0 && (text === ";" || text === "=" || text === "=>")) return null;
    if (depth === 0 && text === "{" && code[cursor - 1].text !== ":") return cursor;
    if (openers.has(text)) depth++;
    if (closers.has(text)) depth--;
    if (depth < 0) return null;
  }
  return null;
}

export function matchingClose(code: readonly SourceToken[], open: number): number | null {
  let depth = 0;
  for (let cursor = open; cursor < code.length; cursor++) {
    if (openers.has(code[cursor].text)) depth++;
    if (closers.has(code[cursor].text)) depth--;
    if (depth === 0) return cursor;
  }
  return null;
}

function isArrow(code: readonly SourceToken[], index: number): boolean {
  return code[index].text === "=" && code[index + 1]?.text === ">";
}

function headOf(
  code: readonly SourceToken[],
  index: number,
): { readonly name: string; readonly line: number } {
  if (!isArrow(code, index)) return { name: code[index].text, line: code[index].line };
  const open = parameterListOpen(code, index - 1);
  if (open === null) return { name: "(anonymous)", line: code[index].line };
  const named = code[open - 1]?.text === "=" && code[open - 2]?.kind === "identifier";
  return { name: named ? code[open - 2].text : "(anonymous)", line: code[open].line };
}

function parameterListOpen(code: readonly SourceToken[], closeIndex: number): number | null {
  if (code[closeIndex]?.text !== ")") return null;
  let depth = 0;
  for (let cursor = closeIndex; cursor >= 0; cursor--) {
    if (code[cursor].text === ")") depth++;
    if (code[cursor].text === "(") depth--;
    if (depth === 0) return cursor;
  }
  return null;
}
