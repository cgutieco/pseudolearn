import type { Parsed } from "../catalog/catalog_types.ts";
import { parseScreenshotStory, type ScreenshotStory } from "../story/screenshot_story.ts";
import type { FileStore } from "./ports.ts";

export async function loadScreenshotStory(files: FileStore, path: string): Promise<Parsed<ScreenshotStory>> {
  const bytes = await files.readBytesIfPresent(path);
  if (bytes === null) {
    return { ok: false, errors: [{ path, message: "the story file does not exist" }] };
  }
  try {
    return parseScreenshotStory(JSON.parse(new TextDecoder().decode(bytes)));
  } catch (error) {
    return { ok: false, errors: [{ path, message: `the story is not valid JSON: ${String(error)}` }] };
  }
}
