import {
  LANGUAGES,
  STORES,
  type Catalog,
  type Language,
  type LexiconEntry,
  type LoudnessTarget,
  type Parsed,
  type StoreId,
} from "./catalog_types.ts";
import { JsonReader, type JsonObject } from "./json_reader.ts";
import { parseCodecProfiles } from "./parse_codec_profiles.ts";
import { parseSlots } from "./parse_slots.ts";

const ROOT_KEYS = ["localesByLanguage", "loudness", "codecProfiles", "slots"];

export function parseCatalog(slotsDocument: unknown, lexiconDocument: unknown): Parsed<Catalog> {
  const reader = new JsonReader();
  const document = reader.object(slotsDocument, "$");
  reader.keys(document, "$", ROOT_KEYS);
  const profiles = parseCodecProfiles(reader, document);
  const catalog: Catalog = {
    slots: parseSlots({ reader, profiles }, document),
    loudness: parseLoudness(reader, reader.object(document["loudness"], "loudness")),
    lexicon: parseLexicon(reader, reader.object(lexiconDocument, "lexicon")),
    localesByLanguage: parseLocales(reader, reader.object(document["localesByLanguage"], "localesByLanguage")),
  };
  return reader.errors.length === 0 ? { ok: true, value: catalog } : { ok: false, errors: reader.errors };
}

function parseLoudness(reader: JsonReader, entry: JsonObject): LoudnessTarget {
  return {
    integratedLufs: reader.number(entry["integratedLufs"], "loudness.integratedLufs", { min: -40, max: -6 }),
    toleranceLu: reader.number(entry["toleranceLu"], "loudness.toleranceLu", { min: 0, max: 3 }),
    truePeakDb: reader.number(entry["truePeakDb"], "loudness.truePeakDb", { min: -9, max: 0 }),
  };
}

function parseLexicon(reader: JsonReader, document: JsonObject): Record<StoreId, readonly LexiconEntry[]> {
  reader.keys(document, "lexicon", ["shared", ...STORES]);
  const shared = parseEntries(reader, document["shared"], "lexicon.shared");
  const byStore = {} as Record<StoreId, readonly LexiconEntry[]>;
  for (const store of STORES) {
    byStore[store] = [...shared, ...parseEntries(reader, document[store], `lexicon.${store}`)];
  }
  return byStore;
}

function parseEntries(reader: JsonReader, value: unknown, path: string): readonly LexiconEntry[] {
  return reader.array(value, path).map((item, index) => {
    const entry = reader.object(item, `${path}[${index}]`);
    const source = reader.text(entry["pattern"], `${path}[${index}].pattern`);
    return { id: reader.text(entry["id"], `${path}[${index}].id`), pattern: compile(reader, source, `${path}[${index}]`) };
  });
}

function compile(reader: JsonReader, source: string, path: string): RegExp {
  try {
    return new RegExp(source, "iu");
  } catch {
    reader.fail(path, "pattern is not a valid regular expression");
    return /$^/u;
  }
}

function parseLocales(reader: JsonReader, document: JsonObject): Record<StoreId, Record<Language, readonly string[]>> {
  const locales = {} as Record<StoreId, Record<Language, readonly string[]>>;
  for (const store of STORES) {
    const byLanguage = reader.object(document[store], `localesByLanguage.${store}`);
    const entry = {} as Record<Language, readonly string[]>;
    for (const language of LANGUAGES) {
      entry[language] = reader.array(byLanguage[language], `localesByLanguage.${store}.${language}`)
        .map((locale, index) => reader.text(locale, `localesByLanguage.${store}.${language}[${index}]`));
    }
    locales[store] = entry;
  }
  return locales;
}
