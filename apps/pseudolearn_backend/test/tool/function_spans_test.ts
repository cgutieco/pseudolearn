import { assertEquals } from "@std/assert";
import { functionSpans } from "../../tool/function_spans.ts";
import { checkSourceFile } from "../../tool/check_architecture.ts";
import type { ArchitectureRules } from "../../tool/architecture_rules.ts";
import { tokenize } from "../../tool/source_lexer.ts";

const rules: ArchitectureRules = JSON.parse(Deno.readTextFileSync("architecture.json"));

function spans(source: string) {
  return functionSpans(tokenize(source)).map((span) => [span.name, span.startLine, span.endLine]);
}

function bodyOf(lines: number): string {
  return Array.from({ length: lines }, (_, index) => `  const v${index} = ${index};`).join("\n");
}

Deno.test("a declaration, a method and an arrow function are measured", () => {
  const source = [
    "function plain(a: number) {",
    "  return a;",
    "}",
    "class Box {",
    "  open(value: string): boolean {",
    "    return value.length > 0;",
    "  }",
    "}",
    "const arrow = (x: number) => {",
    "  return x;",
    "};",
  ].join("\n");

  assertEquals(spans(source), [["plain", 1, 3], ["open", 5, 7], ["arrow", 9, 11]]);
});

Deno.test("an arrow function without a name is reported as anonymous", () => {
  assertEquals(spans("run(() => {\n  work();\n});\n"), [["(anonymous)", 1, 3]]);
});

Deno.test("control flow blocks are not functions", () => {
  const source = "if (a) {\n  b();\n}\nwhile (c) {\n  d();\n}\nswitch (e) {\n}\n";

  assertEquals(spans(source), []);
});

Deno.test("a return type with generics and a promise does not hide the body", () => {
  const source =
    "async function load(id: string): Promise<Map<string, number>> {\n  return new Map();\n}\n";

  assertEquals(spans(source), [["load", 1, 3]]);
});

Deno.test("a call that is followed by a block-less expression is not a function", () => {
  assertEquals(spans("const x = call(1, 2);\nexport const y = other(3);\n"), []);
});

Deno.test("an empty file has no functions", () => {
  assertEquals(spans(""), []);
});

Deno.test("negative: a function longer than the limit is rejected in function code", () => {
  const long = `export function big() {\n${bodyOf(rules.limits.function_lines)}\n}\n`;
  const found = checkSourceFile(
    {
      path: "supabase/functions/sample/domain/big.ts",
      source: long,
      tokens: tokenize(long),
    },
    rules,
  ).map((violation) => violation.rule);

  assertEquals(found, ["SIZE-FUNCTION-LINES"]);
});

Deno.test("a function exactly at the limit is accepted", () => {
  const exact = `export function fit() {\n${bodyOf(rules.limits.function_lines - 2)}\n}\n`;
  const found = checkSourceFile(
    {
      path: "supabase/functions/sample/domain/fit.ts",
      source: exact,
      tokens: tokenize(exact),
    },
    rules,
  );

  assertEquals(found, []);
});

Deno.test("test and tool code is exempt from the function limit", () => {
  const long = `export function big() {\n${bodyOf(rules.limits.function_lines)}\n}\n`;

  assertEquals(
    checkSourceFile({ path: "test/big.ts", source: long, tokens: tokenize(long) }, rules),
    [],
  );
});
