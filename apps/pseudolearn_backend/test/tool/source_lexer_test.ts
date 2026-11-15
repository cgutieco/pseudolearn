import { assertEquals } from "@std/assert";
import { tokenize } from "../../tool/source_lexer.ts";

function kinds(source: string, kind: string): string[] {
  return tokenize(source).filter((token) => token.kind === kind).map((token) => token.text);
}

Deno.test("finds line and block comments with their line numbers", () => {
  const tokens = tokenize("const a = 1;\n// line\n/* block\nspans */ const b = 2;");
  const comments = tokens.filter((token) => token.kind === "comment");

  assertEquals(comments.map((token) => [token.text, token.line]), [
    ["// line", 2],
    ["/* block\nspans */", 3],
  ]);
  assertEquals(tokens.find((token) => token.text === "b")?.line, 4);
});

Deno.test("comment markers inside strings are not comments", () => {
  const source = `const url = "https://appleid.apple.com"; const s = '/* no */';`;

  assertEquals(kinds(source, "comment"), []);
  assertEquals(kinds(source, "string"), ['"https://appleid.apple.com"', "'/* no */'"]);
});

Deno.test("template literals with nested expressions are not comments", () => {
  const source = "const t = `a // ${ { x: `inner // ${1}` }.x } /* b */`; // real";

  assertEquals(kinds(source, "comment"), ["// real"]);
});

Deno.test("regex literals containing slashes are not comments", () => {
  const source = 'const r = value.replace(/\\/+$/, ""); const q = /[/]*/g;';

  assertEquals(kinds(source, "comment"), []);
  assertEquals(kinds(source, "regex"), ["/\\/+$/", "/[/]*/g"]);
});

Deno.test("division is not mistaken for a regex", () => {
  const source = "const half = total / 2 / count; const x = (a) / b;";

  assertEquals(kinds(source, "regex"), []);
});

Deno.test("unterminated constructs end at the source boundary", () => {
  assertEquals(kinds("/* open", "comment"), ["/* open"]);
  assertEquals(kinds("`open", "template"), ["`open"]);
  assertEquals(tokenize("").length, 0);
});

Deno.test("escaped quotes do not end a string early", () => {
  assertEquals(kinds(`const s = "a \\" // b"; // c`, "comment"), ["// c"]);
});
