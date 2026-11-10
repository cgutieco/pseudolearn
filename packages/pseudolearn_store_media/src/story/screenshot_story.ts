import { LANGUAGES, type Language, type Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";
import { headlineRuns } from "./headline_runs.ts";

export const CHAPTER_KINDS = ["manifesto", "device"] as const;
export type ChapterKind = (typeof CHAPTER_KINDS)[number];

export const APP_THEMES = ["light", "dark"] as const;
export type AppTheme = (typeof APP_THEMES)[number];

export const PALETTES = ["paper", "mint", "sand", "deep", "peach", "mist"] as const;
export type PaletteId = (typeof PALETTES)[number];

export type LocalizedText = Readonly<Record<Language, string>>;
export type LocalizedLines = Readonly<Record<Language, readonly string[]>>;
export type Pin = { readonly x: number; readonly y: number };

export type Chapter = {
  readonly id: string;
  readonly kind: ChapterKind;
  readonly plate: string;
  readonly appTheme: AppTheme;
  readonly palette: PaletteId;
  readonly headline: LocalizedText;
  readonly subline: LocalizedText | null;
  readonly code: LocalizedLines | null;
  readonly focus: string | null;
  readonly pin: Pin | null;
  readonly note: LocalizedText | null;
};

export type ScreenshotStory = {
  readonly id: string;
  readonly texture: LocalizedLines;
  readonly chapters: readonly Chapter[];
};

export const MAXIMUM_HEADLINE_LINES = 4;
const STORY_KEYS = ["id", "texture", "chapters"];
const CHAPTER_KEYS = ["id", "kind", "plate", "appTheme", "palette", "headline", "subline", "code", "focus", "pin", "note"];
const REQUIRED_BY_KIND: Readonly<Record<ChapterKind, readonly string[]>> = {
  manifesto: ["subline", "code"],
  device: ["focus", "pin", "note"],
};

export function parseScreenshotStory(document: unknown): Parsed<ScreenshotStory> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", STORY_KEYS);
  const story: ScreenshotStory = {
    id: reader.text(root["id"], "id"),
    texture: parseLines(reader, root["texture"], "texture"),
    chapters: reader.array(root["chapters"], "chapters")
      .map((value, index) => parseChapter(reader, reader.object(value, `chapters[${index}]`), `chapters[${index}]`)),
  };
  const ids = story.chapters.map((chapter) => chapter.id);
  if (ids.length === 0) {
    reader.fail("chapters", "a story needs at least one chapter");
  }
  if (new Set(ids).size !== ids.length) {
    reader.fail("chapters", "chapter ids must be unique");
  }
  return reader.errors.length === 0 ? { ok: true, value: story } : { ok: false, errors: reader.errors };
}

export type RecordedScene = Pick<Chapter, "plate" | "appTheme">;

export function platePathParts(chapter: RecordedScene, place: { device: string; language: Language }): readonly string[] {
  return [chapter.plate, place.device, chapter.appTheme, place.language];
}

function parseChapter(reader: JsonReader, entry: JsonObject, path: string): Chapter {
  reader.keys(entry, path, CHAPTER_KEYS);
  const kind = reader.member(entry["kind"], `${path}.kind`, CHAPTER_KINDS);
  for (const key of REQUIRED_BY_KIND[kind]) {
    if (entry[key] === undefined) {
      reader.fail(`${path}.${key}`, `a ${kind} chapter needs ${key}`);
    }
  }
  const optional = <T>(key: string, parse: (value: unknown, at: string) => T): T | null =>
    entry[key] === undefined ? null : parse(entry[key], `${path}.${key}`);
  return {
    id: reader.text(entry["id"], `${path}.id`),
    kind,
    plate: reader.text(entry["plate"], `${path}.plate`),
    appTheme: reader.member(entry["appTheme"], `${path}.appTheme`, APP_THEMES),
    palette: reader.member(entry["palette"], `${path}.palette`, PALETTES),
    headline: parseHeadline(reader, entry["headline"], `${path}.headline`),
    subline: optional("subline", (value, at) => parseText(reader, value, at)),
    code: optional("code", (value, at) => parseLines(reader, value, at)),
    focus: optional("focus", (value, at) => reader.text(value, at)),
    pin: optional("pin", (value, at) => parsePin(reader, value, at)),
    note: optional("note", (value, at) => parseText(reader, value, at)),
  };
}

function parseHeadline(reader: JsonReader, value: unknown, path: string): LocalizedText {
  const headline = parseText(reader, value, path);
  for (const language of LANGUAGES) {
    const runs = headlineRuns(headline[language]);
    if (!runs) {
      reader.fail(`${path}.${language}`, "emphasis marks must come in pairs");
    } else if (runs.length > MAXIMUM_HEADLINE_LINES || runs.some((line) => line.length === 0)) {
      reader.fail(`${path}.${language}`, `needs 1 to ${MAXIMUM_HEADLINE_LINES} non-empty lines`);
    }
  }
  return headline;
}

function parseText(reader: JsonReader, value: unknown, path: string): LocalizedText {
  const entry = reader.object(value, path);
  reader.keys(entry, path, LANGUAGES);
  return { es: reader.text(entry["es"], `${path}.es`), en: reader.text(entry["en"], `${path}.en`) };
}

function parseLines(reader: JsonReader, value: unknown, path: string): LocalizedLines {
  const entry = reader.object(value, path);
  reader.keys(entry, path, LANGUAGES);
  const lines = (language: Language) => reader.array(entry[language], `${path}.${language}`)
    .map((line, index) => (typeof line === "string" ? line : reader.text(line, `${path}.${language}[${index}]`)));
  return { es: lines("es"), en: lines("en") };
}

function parsePin(reader: JsonReader, value: unknown, path: string): Pin {
  const entry = reader.object(value, path);
  reader.keys(entry, path, ["x", "y"]);
  const unit = { min: 0, max: 1 };
  return { x: reader.number(entry["x"], `${path}.x`, unit), y: reader.number(entry["y"], `${path}.y`, unit) };
}
