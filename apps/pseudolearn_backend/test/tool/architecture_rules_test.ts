import { assertEquals } from "@std/assert";
import {
  type ArchitectureRules,
  findUndeclaredLayerViolations,
  importSpecifiers,
  layerOf,
  resolveRelative,
} from "../../tool/architecture_rules.ts";
import { checkSourceFile } from "../../tool/check_architecture.ts";
import { tokenize } from "../../tool/source_lexer.ts";

const rules: ArchitectureRules = JSON.parse(Deno.readTextFileSync("architecture.json"));
const root = "supabase/functions/sample";

function check(path: string, source: string) {
  return checkSourceFile({ path, source, tokens: tokenize(source) }, rules)
    .map((found) => found.rule);
}

Deno.test("a compliant application file has no violations", () => {
  const source = 'import type { X } from "../domain/x.ts";\nexport const y = 1;\n';

  assertEquals(check(`${root}/application/use_case.ts`, source), []);
});

Deno.test("negative: a comment anywhere is rejected, including tests and tools", () => {
  assertEquals(check(`${root}/domain/a.ts`, "// explain\nexport const a = 1;"), [
    "QUALITY-NO-COMMENTS",
  ]);
  assertEquals(check("test/a_test.ts", "/** doc */ Deno.test('x', () => {});"), [
    "QUALITY-NO-COMMENTS",
  ]);
});

Deno.test("negative: an inner layer importing an outer layer is rejected", () => {
  const source = 'import { handler } from "../http/handler.ts";';

  assertEquals(check(`${root}/application/use_case.ts`, source), ["LAYER-DIRECTION"]);
  assertEquals(check(`${root}/domain/x.ts`, 'export * from "../application/y.ts";'), [
    "LAYER-DIRECTION",
  ]);
});

Deno.test("negative: remote, bare and escaping imports are rejected in function code", () => {
  assertEquals(check(`${root}/infrastructure/a.ts`, 'import x from "npm:@supabase/supabase-js";'), [
    "LAYER-DIRECTION",
  ]);
  assertEquals(check(`${root}/infrastructure/a.ts`, 'import x from "@std/assert";'), [
    "LAYER-DIRECTION",
  ]);
  assertEquals(
    check(`${root}/infrastructure/a.ts`, 'const m = await import("../../../tool/x.ts");'),
    [
      "LAYER-DIRECTION",
    ],
  );
});

Deno.test("negative: forbidden identifiers are rejected by layer, not as property names", () => {
  assertEquals(check(`${root}/http/a.ts`, "const e = Deno.env.get('X');"), [
    "LAYER-FORBIDDEN-IDENTIFIER",
  ]);
  assertEquals(check(`${root}/infrastructure/a.ts`, "await fetch(url);"), [
    "LAYER-FORBIDDEN-IDENTIFIER",
  ]);
  assertEquals(check(`${root}/infrastructure/a.ts`, "await this.options.fetch(url);"), []);
  assertEquals(check(`${root}/index.ts`, "Deno.serve(handler); fetch(url);"), []);
});

Deno.test("negative: a function file longer than the limit is rejected, tests are exempt", () => {
  const long = "export const a = 1;\n".repeat(rules.limits.file_lines + 1);

  assertEquals(check(`${root}/domain/long.ts`, long), ["SIZE-FILE-LINES"]);
  assertEquals(check("test/long_test.ts", long), []);
});

Deno.test("a file exactly at the limit is accepted", () => {
  const atLimit = "export const a = 1;\n".repeat(rules.limits.file_lines);

  assertEquals(check(`${root}/domain/limit.ts`, atLimit), []);
});

Deno.test("negative: undeclared folders and missing layers are reported", () => {
  const entries = ["domain", "application", "infrastructure", "http", "index.ts", "utils"];
  const complete = ["domain", "application", "infrastructure", "http", "index.ts"];

  assertEquals(findUndeclaredLayerViolations("sample", entries, rules).length, 1);
  assertEquals(findUndeclaredLayerViolations("sample", complete, rules), []);
  assertEquals(findUndeclaredLayerViolations("sample", ["index.ts"], rules).length, 4);
});

Deno.test("layerOf maps function paths and ignores files outside functions", () => {
  assertEquals(layerOf(`${root}/index.ts`, rules)?.name, "composition");
  assertEquals(layerOf(`${root}/http/nested/a.ts`, rules)?.name, "http");
  assertEquals(layerOf("tool/a.ts", rules), null);
  assertEquals(layerOf(`${root}`, rules), null);
});

Deno.test("resolveRelative normalises dot segments", () => {
  assertEquals(resolveRelative("a/b/c.ts", "../d/e.ts"), "a/d/e.ts");
  assertEquals(resolveRelative("a/b/c.ts", "./e.ts"), "a/b/e.ts");
});

Deno.test("importSpecifiers finds static, type, re-export and dynamic imports", () => {
  const source =
    'import a from "./a.ts";\nimport type { B } from "./b.ts";\nexport { c } from "./c.ts";\nimport "./d.ts";\nawait import("./e.ts");\nconst s = "from";';

  assertEquals(importSpecifiers(tokenize(source)).map((found) => found.specifier), [
    "./a.ts",
    "./b.ts",
    "./c.ts",
    "./d.ts",
    "./e.ts",
  ]);
});
