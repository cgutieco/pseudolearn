import { readFile } from "node:fs/promises";
import { join } from "node:path";
import type { Catalog, Parsed } from "../catalog/catalog_types.ts";
import { parseCatalog } from "../catalog/parse_catalog.ts";

export async function loadCatalog(packageRoot: string): Promise<Parsed<Catalog>> {
  const directory = join(packageRoot, "catalog");
  const [slots, lexicon] = await Promise.all([
    readFile(join(directory, "slots.json"), "utf8"),
    readFile(join(directory, "lexicon.json"), "utf8"),
  ]);
  try {
    return parseCatalog(JSON.parse(slots), JSON.parse(lexicon));
  } catch (error) {
    return { ok: false, errors: [{ path: directory, message: `invalid JSON: ${String(error)}` }] };
  }
}
