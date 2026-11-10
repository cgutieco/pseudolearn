import { LANGUAGES } from "../catalog/catalog_types.ts";
import type { JsonObject, JsonReader } from "../catalog/json_reader.ts";
import { headlineRuns } from "./headline_runs.ts";
import type { LocalizedText, Pin } from "./screenshot_story.ts";

export const CAPTION_ROLES = ["headline", "note", "disclosure"] as const;
export type CaptionRole = (typeof CAPTION_ROLES)[number];

export type OverlayWindow = { readonly fromSeconds: number; readonly toSeconds: number };

export const CAPTION_ANCHORS = ["top", "bottom"] as const;
export type CaptionAnchor = (typeof CAPTION_ANCHORS)[number];

export type Caption = OverlayWindow & { readonly role: CaptionRole; readonly text: LocalizedText; readonly anchor: CaptionAnchor | null };

export type PreviewPin = OverlayWindow & { readonly focus: string; readonly pin: Pin; readonly note: LocalizedText };

const CAPTION_KEYS = ["role", "text", "anchor", "from", "to"];
const PIN_KEYS = ["focus", "pin", "note", "from", "to"];
const SECONDS = { min: 0, max: 600 };

export function parseCaptions(reader: JsonReader, value: unknown, path: string): readonly Caption[] {
  return reader.array(value, path).map((item, index) => {
    const at = `${path}[${index}]`;
    const entry = reader.object(item, at);
    reader.keys(entry, at, CAPTION_KEYS);
    return {
      role: reader.member(entry["role"], `${at}.role`, CAPTION_ROLES),
      text: parseMarkedText(reader, entry["text"], `${at}.text`),
      anchor: entry["anchor"] === undefined ? null : reader.member(entry["anchor"], `${at}.anchor`, CAPTION_ANCHORS),
      ...parseWindow(reader, entry, at),
    };
  });
}

export function parsePins(reader: JsonReader, value: unknown, path: string): readonly PreviewPin[] {
  return reader.array(value, path).map((item, index) => {
    const at = `${path}[${index}]`;
    const entry = reader.object(item, at);
    reader.keys(entry, at, PIN_KEYS);
    const point = reader.object(entry["pin"], `${at}.pin`);
    reader.keys(point, `${at}.pin`, ["x", "y"]);
    return {
      focus: reader.text(entry["focus"], `${at}.focus`),
      pin: { x: reader.number(point["x"], `${at}.pin.x`, { min: 0, max: 1 }), y: reader.number(point["y"], `${at}.pin.y`, { min: 0, max: 1 }) },
      note: parseMarkedText(reader, entry["note"], `${at}.note`),
      ...parseWindow(reader, entry, at),
    };
  });
}

function parseWindow(reader: JsonReader, entry: JsonObject, path: string): OverlayWindow {
  const fromSeconds = reader.number(entry["from"], `${path}.from`, SECONDS);
  const toSeconds = reader.number(entry["to"], `${path}.to`, SECONDS);
  if (toSeconds <= fromSeconds) {
    reader.fail(`${path}.to`, "an overlay must leave after it enters");
  }
  return { fromSeconds, toSeconds };
}

function parseMarkedText(reader: JsonReader, value: unknown, path: string): LocalizedText {
  const entry = reader.object(value, path);
  reader.keys(entry, path, LANGUAGES);
  const text = { es: reader.text(entry["es"], `${path}.es`), en: reader.text(entry["en"], `${path}.en`) };
  for (const language of LANGUAGES) {
    if (!headlineRuns(text[language])) {
      reader.fail(`${path}.${language}`, "emphasis marks must come in pairs");
    }
  }
  return text;
}
