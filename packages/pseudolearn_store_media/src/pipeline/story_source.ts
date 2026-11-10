import type { Parsed } from "../catalog/catalog_types.ts";
import { parseDesktopStory, type DesktopStory } from "../story/desktop_story.ts";
import { parseScreenshotStory, type ScreenshotStory } from "../story/screenshot_story.ts";
import { parseThermostatStory, type ThermostatStory } from "../story/thermostat_story.ts";
import type { FileStore } from "./ports.ts";

export function loadScreenshotStory(files: FileStore, path: string): Promise<Parsed<ScreenshotStory>> {
  return loadStory(files, path, parseScreenshotStory);
}

export function loadDesktopStory(files: FileStore, path: string): Promise<Parsed<DesktopStory>> {
  return loadStory(files, path, parseDesktopStory);
}

export function loadThermostatStory(files: FileStore, path: string): Promise<Parsed<ThermostatStory>> {
  return loadStory(files, path, parseThermostatStory);
}

async function loadStory<T>(files: FileStore, path: string, parse: (document: unknown) => Parsed<T>): Promise<Parsed<T>> {
  const bytes = await files.readBytesIfPresent(path);
  if (bytes === null) {
    return { ok: false, errors: [{ path, message: "the story file does not exist" }] };
  }
  try {
    return parse(JSON.parse(new TextDecoder().decode(bytes)));
  } catch (error) {
    return { ok: false, errors: [{ path, message: `the story is not valid JSON: ${String(error)}` }] };
  }
}
