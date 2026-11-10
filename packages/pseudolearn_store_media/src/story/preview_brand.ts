import { LANGUAGES } from "../catalog/catalog_types.ts";
import type { JsonReader } from "../catalog/json_reader.ts";
import type { LocalizedText } from "./screenshot_story.ts";

export type BrandCards = { readonly openingSeconds: number; readonly closingSeconds: number };

export type Disclosure = { readonly plates: readonly string[]; readonly text: LocalizedText };

const CARD_SECONDS = { min: 0, max: 10 };

export function parseBrandCards(reader: JsonReader, value: unknown, path: string): BrandCards | null {
  if (value === undefined) {
    return null;
  }
  const entry = reader.object(value, path);
  reader.keys(entry, path, ["opening", "closing"]);
  return {
    openingSeconds: reader.number(entry["opening"], `${path}.opening`, CARD_SECONDS),
    closingSeconds: reader.number(entry["closing"], `${path}.closing`, CARD_SECONDS),
  };
}

export function parseDisclosure(reader: JsonReader, value: unknown, path: string): Disclosure | null {
  if (value === undefined) {
    return null;
  }
  const entry = reader.object(value, path);
  reader.keys(entry, path, ["plates", "text"]);
  const text = reader.object(entry["text"], `${path}.text`);
  reader.keys(text, `${path}.text`, LANGUAGES);
  return {
    plates: reader.array(entry["plates"], `${path}.plates`).map((plate, index) => reader.text(plate, `${path}.plates[${index}]`)),
    text: { es: reader.text(text["es"], `${path}.text.es`), en: reader.text(text["en"], `${path}.text.en`) },
  };
}
