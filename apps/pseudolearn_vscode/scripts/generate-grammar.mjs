import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const extensionDirectory = fileURLToPath(new URL("..", import.meta.url));
const exportPath = resolve(
  extensionDirectory,
  "../../packages/pseudolearn_spec/specifications/export.json",
);
const generatedFiles = [
  ["media/pseudolearn.tmLanguage.json", buildGrammar],
  ["media/language-configuration.json", buildLanguageConfiguration],
];

export { buildGrammar, buildLanguageConfiguration, verifyGeneratedFile };

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await generate(process.argv.includes("--check"));
}

async function generate(checkOnly) {
  const exportText = await readFile(exportPath, "utf8");
  const exported = JSON.parse(exportText);
  const sourceHash = createHash("sha256").update(exportText).digest("hex");
  for (const [relativePath, build] of generatedFiles) {
    const targetPath = resolve(extensionDirectory, relativePath);
    const expectedText = `${JSON.stringify(build(exported, sourceHash), null, 2)}\n`;
    if (checkOnly) {
      await verifyGeneratedFile(targetPath, expectedText);
    } else {
      await mkdir(dirname(targetPath), { recursive: true });
      await writeFile(targetPath, expectedText);
    }
  }
}

function buildGrammar(exported, sourceHash) {
  const identifier = lexicalDefinition(exported, "LANG.LEXICAL.IDENTIFIER", "textmateIdentifier");
  const number = lexicalDefinition(exported, "LANG.LEXICAL.NUMBER-LITERAL", "textmateNumber");
  const comment = lexicalDefinition(exported, "LANG.LEXICAL.COMMENT", "textmateComment");
  const literal = lexicalDefinition(exported, "LANG.LEXICAL.TEXT-LITERAL", "textmateTextLiteral");
  const accentFold = lexicalDefinition(
    exported,
    "LANG.LEXICAL.KEYWORD",
    "textmateAccentFold",
  );
  const keywords = keywordPattern(exported.resources.vocabulary, accentFold);
  return {
    name: "PseudoLearn",
    scopeName: "source.pseudolearn",
    sourceHash,
    patterns: [
      { match: `${escapePattern(comment.start)}.*$`, name: "comment.line.pseudolearn" },
      ...literalPatterns(literal),
      { match: number.real, name: "constant.numeric.real.pseudolearn" },
      { match: number.integer, name: "constant.numeric.integer.pseudolearn" },
      { match: keywords, name: "keyword.other.pseudolearn" },
      {
        match: `(?<![\\p{L}\\p{N}_])${identifier.start}${identifier.continue}*(?![\\p{L}\\p{N}_])`,
        name: "variable.other.pseudolearn",
      },
    ],
  };
}

function buildLanguageConfiguration(exported) {
  const comment = lexicalDefinition(exported, "LANG.LEXICAL.COMMENT", "textmateComment");
  const identifier = lexicalDefinition(exported, "LANG.LEXICAL.IDENTIFIER", "textmateIdentifier");
  const literal = lexicalDefinition(exported, "LANG.LEXICAL.TEXT-LITERAL", "textmateTextLiteral");
  const bracketPairs = uniquePairs(languageBracketPairs(exported.resources.vocabulary));
  const quotePairs = literal.delimiters.map((delimiter) => [delimiter, delimiter]);
  const allPairs = uniquePairs([...bracketPairs, ...quotePairs]);
  return {
    comments: { lineComment: comment.start },
    brackets: bracketPairs,
    autoClosingPairs: [
      ...bracketPairs.map(([open, close]) => ({ open, close })),
      ...quotePairs.map(([open, close]) => ({ open, close, notIn: ["string", "comment"] })),
    ],
    surroundingPairs: allPairs,
    wordPattern: `(${identifier.start}${identifier.continue}*)`,
  };
}

function lexicalDefinition(exported, specificationId, definitionId) {
  const specification = exported.specifications.find(
    (item) => item.metadata.id === specificationId,
  );
  const definition = specification?.blocks.find(
    (item) => item.kind === "definicion" && item.fields.termino === definitionId,
  );
  if (!definition?.fields.valor) {
    throw new Error(`Missing SEE lexical definition ${definitionId}`);
  }
  return definition.fields.valor;
}

function keywordPattern(vocabulary, accentFold) {
  const spellings = Object.values(vocabulary).flatMap((entry) => [
    ...languageSpellings(entry, "es").map((spelling) => [spelling, true]),
    ...languageSpellings(entry, "en").map((spelling) => [spelling, false]),
  ]);
  const alternatives = [
    ...new Set(
      spellings
        .filter(([spelling]) => isWordSpelling(spelling))
        .map(([spelling, spanish]) =>
          spanish ? spanishKeywordRegex(spelling, accentFold) : keywordRegex(spelling),
        ),
    ),
  ]
    .sort((left, right) => right.length - left.length);
  return `(?<![\\p{L}\\p{N}_])(?i:(?:${alternatives.join("|")}))(?![\\p{L}\\p{N}_])`;
}

function languageSpellings(entry, language) {
  return [entry.lexemas?.[language], ...(entry.alias?.[language] ?? [])].filter(
    (spelling) => typeof spelling === "string",
  );
}

function isWordSpelling(spelling) {
  return typeof spelling === "string" && /[\p{L}_]/u.test(spelling);
}

function keywordRegex(spelling) {
  return [...spelling]
    .map((glyph) => (glyph === " " ? "\\s+" : escapePattern(glyph)))
    .join("");
}

function spanishKeywordRegex(spelling, accentFold) {
  return [...spelling]
    .map((glyph) => {
      if (glyph === " ") {
        return "\\s+";
      }
      const folded = glyph.toLowerCase();
      const base = Object.keys(accentFold).find((candidate) =>
        [candidate, ...accentFold[candidate]].includes(folded),
      );
      const variants = base ? [base, ...accentFold[base]] : [glyph];
      const decomposedVariants = variants.flatMap((variant) => [variant, variant.normalize("NFD")]);
      const alternatives = [...new Set(decomposedVariants)].map(escapePattern);
      return `(?:${alternatives.join("|")})`;
    })
    .join("");
}

function escapePattern(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function literalPatterns(literal) {
  const escapes = literal.escapeCodes.map(escapePattern).join("|");
  return literal.delimiters.map((delimiter) => {
    const quoted = escapePattern(delimiter);
    return {
      begin: quoted,
      end: `(?:${quoted}|$)`,
      name: "string.quoted.pseudolearn",
      patterns: [{ match: `\\\\(?:${escapes})`, name: "constant.character.escape.pseudolearn" }],
    };
  });
}

function languageBracketPairs(vocabulary) {
  return Object.keys(vocabulary)
    .filter((identity) => identity.startsWith("left"))
    .flatMap((identity) => {
      const closing = vocabulary[identity.replace(/^left/, "right")];
      const opening = vocabulary[identity];
      if (!closing) {
        return [];
      }
      const opens = Object.values(opening.lexemas ?? {}).filter(isSingleSymbol);
      const closes = Object.values(closing.lexemas ?? {}).filter(isSingleSymbol);
      return opens.flatMap((open) => closes.map((close) => [open, close]));
    });
}

function isSingleSymbol(value) {
  return typeof value === "string" && [...value].length === 1 && !/[\p{L}\p{N}_]/u.test(value);
}

function uniquePairs(pairs) {
  const unique = new Map(pairs.map((pair) => [JSON.stringify(pair), pair]));
  return [...unique.values()];
}

async function verifyGeneratedFile(targetPath, expectedText) {
  const actualText = await readFile(targetPath, "utf8").catch(() => "");
  if (actualText !== expectedText) {
    throw new Error(`${targetPath} is stale; run pnpm generate:grammar`);
  }
}
