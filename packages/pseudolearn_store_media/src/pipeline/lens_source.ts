import type { Parsed } from "../catalog/catalog_types.ts";
import { parseLensStory, type LensStory } from "../story/lens_story.ts";
import type { FileStore } from "./ports.ts";

export async function loadLensStory(files: FileStore, path: string): Promise<Parsed<LensStory>> {
  const bytes = await files.readBytesIfPresent(path);
  if (bytes === null) {
    return { ok: false, errors: [{ path, message: "the story file does not exist" }] };
  }
  try {
    return parseLensStory(JSON.parse(new TextDecoder().decode(bytes)));
  } catch (error) {
    return { ok: false, errors: [{ path, message: `the story is not valid JSON: ${String(error)}` }] };
  }
}
