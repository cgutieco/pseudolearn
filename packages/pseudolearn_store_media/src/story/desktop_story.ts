import { LANGUAGES, type Parsed } from "../catalog/catalog_types.ts";
import { JsonReader, type JsonObject } from "../catalog/json_reader.ts";
import { APP_THEMES, PALETTES, type AppTheme, type LocalizedText, type PaletteId } from "./screenshot_story.ts";

export type FocusRegion = { readonly x: number; readonly y: number; readonly width: number; readonly height: number };

export type DesktopShot = {
  readonly id: string;
  readonly plate: string;
  readonly appTheme: AppTheme;
  readonly palette: PaletteId;
  readonly critical: { readonly focus: string; readonly region: FocusRegion };
  readonly caption: LocalizedText;
};

export type DesktopStory = { readonly id: string; readonly shots: readonly DesktopShot[] };

const STORY_KEYS = ["id", "shots"];
const SHOT_KEYS = ["id", "plate", "appTheme", "palette", "critical", "caption"];
const UNIT = { min: 0, max: 1 };
const TOLERANCE = 1e-6;

export function parseDesktopStory(document: unknown): Parsed<DesktopStory> {
  const reader = new JsonReader();
  const root = reader.object(document, "$");
  reader.keys(root, "$", STORY_KEYS);
  const shots = reader.array(root["shots"], "shots").map((value, index) => parseShot(reader, reader.object(value, `shots[${index}]`), `shots[${index}]`));
  if (shots.length === 0) {
    reader.fail("shots", "a story needs at least one screenshot");
  }
  if (new Set(shots.map((shot) => shot.id)).size !== shots.length) {
    reader.fail("shots", "screenshot ids must be unique");
  }
  const story = { id: reader.text(root["id"], "id"), shots };
  return reader.errors.length === 0 ? { ok: true, value: story } : { ok: false, errors: reader.errors };
}

function parseShot(reader: JsonReader, entry: JsonObject, path: string): DesktopShot {
  reader.keys(entry, path, SHOT_KEYS);
  const critical = reader.object(entry["critical"], `${path}.critical`);
  reader.keys(critical, `${path}.critical`, ["focus", "region"]);
  return {
    id: reader.text(entry["id"], `${path}.id`),
    plate: reader.text(entry["plate"], `${path}.plate`),
    appTheme: reader.member(entry["appTheme"], `${path}.appTheme`, APP_THEMES),
    palette: reader.member(entry["palette"], `${path}.palette`, PALETTES),
    critical: { focus: reader.text(critical["focus"], `${path}.critical.focus`), region: parseRegion(reader, critical["region"], `${path}.critical.region`) },
    caption: parseCaption(reader, entry["caption"], `${path}.caption`),
  };
}

function parseRegion(reader: JsonReader, value: unknown, path: string): FocusRegion {
  const entry = reader.object(value, path);
  reader.keys(entry, path, ["x", "y", "width", "height"]);
  const region = {
    x: reader.number(entry["x"], `${path}.x`, UNIT),
    y: reader.number(entry["y"], `${path}.y`, UNIT),
    width: reader.number(entry["width"], `${path}.width`, UNIT),
    height: reader.number(entry["height"], `${path}.height`, UNIT),
  };
  if (region.width === 0 || region.height === 0 || region.x + region.width > 1 + TOLERANCE || region.y + region.height > 1 + TOLERANCE) {
    reader.fail(path, "must be a non-empty region inside its focus rectangle");
  }
  return region;
}

function parseCaption(reader: JsonReader, value: unknown, path: string): LocalizedText {
  const entry = reader.object(value, path);
  reader.keys(entry, path, LANGUAGES);
  const caption = {} as Record<(typeof LANGUAGES)[number], string>;
  for (const language of LANGUAGES) {
    caption[language] = reader.text(entry[language], `${path}.${language}`);
  }
  return caption;
}
