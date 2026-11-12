import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import type { Catalog, Slot } from "../../src/catalog/catalog_types.ts";
import { parseCatalog } from "../../src/catalog/parse_catalog.ts";

const directory = fileURLToPath(new URL("../../catalog/", import.meta.url));

export function slotsDocument(): Record<string, unknown> {
  return JSON.parse(readFileSync(`${directory}slots.json`, "utf8")) as Record<string, unknown>;
}

export function lexiconDocument(): Record<string, unknown> {
  return JSON.parse(readFileSync(`${directory}lexicon.json`, "utf8")) as Record<string, unknown>;
}

export function realCatalog(): Catalog {
  const parsed = parseCatalog(slotsDocument(), lexiconDocument());
  if (!parsed.ok) {
    throw new Error(parsed.errors.map((error) => `${error.path}: ${error.message}`).join("\n"));
  }
  return parsed.value;
}

export function slot(id: string): Slot {
  const found = realCatalog().slots.find((entry) => entry.id === id);
  if (!found) {
    throw new Error(`unknown slot ${id}`);
  }
  return found;
}
