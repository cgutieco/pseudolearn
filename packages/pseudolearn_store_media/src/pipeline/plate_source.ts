import type { Language } from "../catalog/catalog_types.ts";
import type { PixelRect } from "../layout/pixel_rect.ts";
import { parsePlateTimeline } from "../story/plate_timeline.ts";
import { platePathParts, type RecordedScene } from "../story/screenshot_story.ts";
import type { FileStore } from "./ports.ts";

export type RecordedPlate = {
  readonly image: Uint8Array | null;
  readonly focus: ReadonlyMap<string, PixelRect> | null;
};

export const PLATE_FRAME = "frame_000001.png";
export const PLATE_TIMELINE = "timeline.json";

export async function readPlate(files: FileStore, root: string, place: { chapter: RecordedScene; device: string; language: Language }): Promise<RecordedPlate> {
  const directory = files.join(root, ...platePathParts(place.chapter, { device: place.device, language: place.language }));
  const image = await files.readBytesIfPresent(files.join(directory, PLATE_FRAME));
  const timelineBytes = await files.readBytesIfPresent(files.join(directory, PLATE_TIMELINE));
  return { image, focus: timelineBytes ? focusOf(timelineBytes) : null };
}

function focusOf(bytes: Uint8Array): ReadonlyMap<string, PixelRect> | null {
  try {
    const parsed = parsePlateTimeline(JSON.parse(new TextDecoder().decode(bytes)));
    const first = parsed.ok ? parsed.value.frames[0] : undefined;
    return first ? new Map(first.focus.map((rect) => [rect.key, { x: rect.x, y: rect.y, width: rect.width, height: rect.height }])) : null;
  } catch {
    return null;
  }
}
