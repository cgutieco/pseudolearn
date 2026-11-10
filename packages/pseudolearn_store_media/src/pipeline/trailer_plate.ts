import type { Language, Slot } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "../audit/finding.ts";
import { INTERFACE_FILE } from "../compose/thermostat_trailer.ts";
import { parsePlateTimeline } from "../story/plate_timeline.ts";
import type { InterfaceTail } from "../story/thermostat_story.ts";
import { PLATE_TIMELINE } from "./plate_source.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import type { ProjectAsset } from "./produce_video.ts";

export type TailPlate = { readonly asset: ProjectAsset | null; readonly findings: readonly Finding[] };

export async function assembleTailPlate(toolbox: Toolbox, place: { root: string; tail: InterfaceTail; language: Language; slot: Slot; output: string; name: string }): Promise<Outcome<TailPlate>> {
  const { files, media } = toolbox;
  const { tail } = place;
  const directory = files.join(place.root, tail.plate, tail.device, tail.appTheme, place.language);
  const bytes = await files.readBytesIfPresent(files.join(directory, PLATE_TIMELINE));
  const parsed = bytes ? safeParse(bytes) : null;
  if (!parsed) {
    return { ok: true, value: { asset: null, findings: [finding("MEDIA-PLATE", place.name, `${directory} holds no readable ${PLATE_TIMELINE}; record the app previews first`)] } };
  }
  if (parsed.pixelWidth !== place.slot.width || parsed.pixelHeight !== place.slot.height) {
    return { ok: true, value: { asset: null, findings: [finding("MEDIA-PLATE", place.name, `${parsed.pixelWidth}×${parsed.pixelHeight} instead of ${place.slot.width}×${place.slot.height}`)] } };
  }
  if (parsed.frames.length / parsed.fps < tail.mediaStart + tail.seconds) {
    return { ok: true, value: { asset: null, findings: [finding("MEDIA-PLATE", place.name, `the plate lasts ${(parsed.frames.length / parsed.fps).toFixed(1)}s, shorter than the tail needs`)] } };
  }
  const assembled = await media.assemblePlate({ directory, files: parsed.frames.map((frame) => frame.file), fps: parsed.fps, outputPath: place.output });
  if (!assembled.ok) {
    return assembled;
  }
  return { ok: true, value: { asset: { name: INTERFACE_FILE, bytes: await files.readBytes(place.output) }, findings: [] } };
}

function safeParse(bytes: Uint8Array) {
  try {
    const parsed = parsePlateTimeline(JSON.parse(new TextDecoder().decode(bytes)));
    return parsed.ok ? parsed.value : null;
  } catch {
    return null;
  }
}
