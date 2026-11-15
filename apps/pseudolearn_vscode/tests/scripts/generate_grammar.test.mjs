import { createRequire } from "node:module";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { expect, it } from "vitest";
import { parseRawGrammar, Registry } from "vscode-textmate";
import {
  buildGrammar,
  buildLanguageConfiguration,
  verifyGeneratedFile,
} from "../../scripts/generate-grammar.mjs";

const require = createRequire(import.meta.url);
const extensionDirectory = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const specificationPath = resolve(
  extensionDirectory,
  "../../packages/pseudolearn_spec/specifications/export.json",
);
const grammarPath = resolve(extensionDirectory, "media/pseudolearn.tmLanguage.json");
const oniguruma = require("vscode-oniguruma");
let onigurumaReady;

it("tokenizes generated keywords, identifiers, strings, comments, and numbers with TextMate", async () => {
  const grammar = await loadGrammar();
  const line = "Algoritmo Main; LÓGICO lógicaVariable; write \"texto \\\" write\"; 3.5 // nota";
  const tokenization = grammar.tokenizeLine(line, null);
  const tokens = tokenization.tokens.map((token) => ({
    text: line.slice(token.startIndex, token.endIndex),
    scopes: token.scopes,
  }));
  expect(tokenWithText(tokens, "Algoritmo").scopes).toContain("keyword.other.pseudolearn");
  expect(tokenWithText(tokens, "LÓGICO").scopes).toContain("keyword.other.pseudolearn");
  expect(tokenWithText(tokens, "lógicaVariable").scopes).toContain("variable.other.pseudolearn");
  expect(tokenWithText(tokens, "write").scopes).toContain("keyword.other.pseudolearn");
  expect(hasScopedText(tokens, "texto", "string.quoted.pseudolearn")).toBe(true);
  expect(hasScopedText(tokens, "nota", "comment.line.pseudolearn")).toBe(true);
  expect(tokens.find((token) => token.text === "3.5")?.scopes).toContain(
    "constant.numeric.real.pseudolearn",
  );
  const incomplete = grammar.tokenizeLine("\"unfinished write", null);
  expect(incomplete.tokens.at(-1)?.scopes).toContain("string.quoted.pseudolearn");
});

it("keeps identifier substrings and contextual vocabulary out of reserved scopes", async () => {
  const grammar = await loadGrammar();
  const line = "algorithmic Cada mywrite";
  const tokens = grammar.tokenizeLine(line, null).tokens.map((token) => ({
    text: line.slice(token.startIndex, token.endIndex),
    scopes: token.scopes,
  }));
  for (const spelling of ["algorithmic", "Cada", "mywrite"]) {
    const token = tokenWithText(tokens, spelling);
    expect(token.scopes).toContain("variable.other.pseudolearn");
    expect(token.scopes).not.toContain("keyword.other.pseudolearn");
  }
});

it("builds language configuration from SEE delimiters and verifies stale files", async () => {
  const exported = JSON.parse(await readFile(specificationPath, "utf8"));
  const configuration = buildLanguageConfiguration(exported);
  expect(configuration.comments.lineComment).toBe("//");
  expect(configuration.brackets).toContainEqual(["(", ")"]);
  expect(configuration.autoClosingPairs).toContainEqual({
    open: "\"",
    close: "\"",
    notIn: ["string", "comment"],
  });
  const directory = await mkdtemp(join(tmpdir(), "pseudolearn-grammar-"));
  const stalePath = join(directory, "generated.json");
  await writeFile(stalePath, "{}\n");
  await expect(verifyGeneratedFile(stalePath, "[]\n")).rejects.toThrow("is stale");
  await rm(directory, { recursive: true, force: true });
});

it("produces deterministic grammar output from the SEE export", async () => {
  const exported = JSON.parse(await readFile(specificationPath, "utf8"));
  const first = buildGrammar(exported, "a".repeat(64));
  const second = buildGrammar(exported, "a".repeat(64));
  expect(first).toEqual(second);
  expect(first.sourceHash).toBe("a".repeat(64));
  const generated = JSON.parse(await readFile(grammarPath, "utf8"));
  expect(generated).toEqual(buildGrammar(exported, generated.sourceHash));
});

async function loadGrammar() {
  if (!onigurumaReady) {
    onigurumaReady = initializeOniguruma();
  }
  await onigurumaReady;
  const generated = JSON.parse(await readFile(grammarPath, "utf8"));
  const registry = new Registry({
    onigLib: Promise.resolve({
      createOnigScanner: (patterns) => new oniguruma.OnigScanner(patterns),
      createOnigString: (value) => new oniguruma.OnigString(value),
    }),
    loadGrammar: async (scopeName) =>
      scopeName === generated.scopeName
        ? parseRawGrammar(JSON.stringify(generated), "pseudolearn.tmLanguage.json")
        : null,
  });
  return registry.loadGrammar(generated.scopeName);
}

async function initializeOniguruma() {
  const onigurumaPath = require.resolve("vscode-oniguruma");
  const wasmPath = join(dirname(onigurumaPath), "onig.wasm");
  const wasm = await readFile(wasmPath);
  await oniguruma.loadWASM(wasm.buffer.slice(wasm.byteOffset, wasm.byteOffset + wasm.byteLength));
}

function tokenWithText(tokens, text) {
  return tokens.find((token) => token.text === text) ?? { text, scopes: [] };
}

function hasScopedText(tokens, text, scope) {
  return tokens.some((token) => token.text.includes(text) && token.scopes.includes(scope));
}
