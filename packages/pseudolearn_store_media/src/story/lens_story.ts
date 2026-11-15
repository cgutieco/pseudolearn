import { LANGUAGES, type Language, type Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";

export const STATEMENT_KINDS = ["terminal", "io", "process", "decision", "join"] as const;
export type StatementKind = (typeof STATEMENT_KINDS)[number];

export type Statement = { readonly text: string; readonly kind: StatementKind };

export type RowRhythm = {
  readonly statementsPerRow: number;
  readonly statementStride: number;
  readonly phaseStride: number;
};

export type LensStory = {
  readonly id: string;
  readonly durationSeconds: number;
  readonly posterSeconds: number;
  readonly rows: RowRhythm;
  readonly statements: Readonly<Record<Language, readonly Statement[]>>;
};

const STORY_KEYS = ["id", "durationSeconds", "posterSeconds", "rows", "statements"];
const ROW_KEYS = ["statementsPerRow", "statementStride", "phaseStride"];

export function parseLensStory(document: unknown): Parsed<LensStory> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", STORY_KEYS);
  const durationSeconds = reader.number(root["durationSeconds"], "durationSeconds", { min: 5, max: 30 });
  const story: LensStory = {
    id: reader.text(root["id"], "id"),
    durationSeconds,
    posterSeconds: reader.number(root["posterSeconds"], "posterSeconds", { min: 0, max: durationSeconds }),
    rows: parseRows(reader, reader.object(root["rows"], "rows")),
    statements: parseStatements(reader, reader.object(root["statements"], "statements")),
  };
  verifyTranslations(reader, story);
  return reader.errors.length === 0 ? { ok: true, value: story } : { ok: false, errors: reader.errors };
}

function parseRows(reader: JsonReader, entry: JsonObject): RowRhythm {
  reader.keys(entry, "rows", ROW_KEYS);
  return {
    statementsPerRow: reader.number(entry["statementsPerRow"], "rows.statementsPerRow", { min: 1, max: 12 }),
    statementStride: reader.number(entry["statementStride"], "rows.statementStride", { min: 1, max: 12 }),
    phaseStride: reader.number(entry["phaseStride"], "rows.phaseStride", { min: 0, max: 1 }),
  };
}

function parseStatements(reader: JsonReader, entry: JsonObject): Record<Language, readonly Statement[]> {
  reader.keys(entry, "statements", LANGUAGES);
  const byLanguage = {} as Record<Language, readonly Statement[]>;
  for (const language of LANGUAGES) {
    const path = `statements.${language}`;
    byLanguage[language] = reader.array(entry[language], path).map((value, index) => {
      const item = reader.object(value, `${path}[${index}]`);
      reader.keys(item, `${path}[${index}]`, ["text", "kind"]);
      return { text: reader.text(item["text"], `${path}[${index}].text`), kind: reader.member(item["kind"], `${path}[${index}].kind`, STATEMENT_KINDS) };
    });
  }
  return byLanguage;
}

function verifyTranslations(reader: JsonReader, story: LensStory): void {
  const [first, ...others] = LANGUAGES.map((language) => story.statements[language]);
  if (!first || first.length === 0) {
    reader.fail("statements", "the lens needs at least one statement");
    return;
  }
  if (story.rows.statementsPerRow > first.length) {
    reader.fail("rows.statementsPerRow", "cannot exceed the number of statements");
  }
  others.forEach((translation, index) => {
    const kindsMatch = translation.length === first.length && translation.every((statement, at) => statement.kind === first[at]?.kind);
    if (!kindsMatch) {
      reader.fail(`statements.${LANGUAGES[index + 1]}`, "must translate every statement with the same kind and order");
    }
  });
}
