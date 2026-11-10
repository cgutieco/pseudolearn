import type { Language, Parsed } from "../catalog/catalog_types.ts";
import { parsePlateTimeline, type PlateTimeline } from "../story/plate_timeline.ts";
import { parsePreviewStory, previewPlatePathParts, type Preview, type PreviewStory } from "../story/preview_story.ts";
import type { FileStore } from "./ports.ts";
import { PLATE_TIMELINE } from "./plate_source.ts";

export type PreviewPlates = {
  readonly timelines: readonly PlateTimeline[];
  readonly directories: readonly string[];
  readonly problems: readonly string[];
};

export async function loadPreviewStory(files: FileStore, path: string): Promise<Parsed<PreviewStory>> {
  const bytes = await files.readBytesIfPresent(path);
  if (bytes === null) {
    return { ok: false, errors: [{ path, message: "the story file does not exist" }] };
  }
  try {
    return parsePreviewStory(JSON.parse(new TextDecoder().decode(bytes)));
  } catch (error) {
    return { ok: false, errors: [{ path, message: `the story is not valid JSON: ${String(error)}` }] };
  }
}

export async function readPreviewPlates(files: FileStore, root: string, place: { preview: Preview; device: string; language: Language }): Promise<PreviewPlates> {
  const timelines: PlateTimeline[] = [];
  const directories: string[] = [];
  for (const scene of place.preview.scenes) {
    const directory = files.join(root, ...previewPlatePathParts(scene, { device: place.device, language: place.language }));
    const bytes = await files.readBytesIfPresent(files.join(directory, PLATE_TIMELINE));
    const parsed = bytes ? parseTimeline(bytes) : null;
    if (!parsed) {
      return { timelines, directories, problems: [`${directory} holds no readable ${PLATE_TIMELINE}`] };
    }
    timelines.push(parsed);
    directories.push(directory);
  }
  return { timelines, directories, problems: [] };
}

function parseTimeline(bytes: Uint8Array): PlateTimeline | null {
  try {
    const parsed = parsePlateTimeline(JSON.parse(new TextDecoder().decode(bytes)));
    return parsed.ok ? parsed.value : null;
  } catch {
    return null;
  }
}
