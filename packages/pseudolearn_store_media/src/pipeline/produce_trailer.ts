import type { Catalog } from "../catalog/catalog_types.ts";
import { MILESTONE_VOICE } from "../audio/score.ts";
import { finding, type Finding } from "../audit/finding.ts";
import { auditImage } from "../audit/image_audit.ts";
import { auditLabels } from "../audit/label_audit.ts";
import { auditContrast } from "../audit/text_audit.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "../compose/editorial_markup.ts";
import { thermostatContrastPairs } from "../compose/thermostat_palette.ts";
import { buildThermostatTrailer } from "../compose/thermostat_trailer.ts";
import { textWidth } from "../layout/glyph_advances.ts";
import { thermostatLayout } from "../layout/thermostat_layout.ts";
import type { ThermostatStory } from "../story/thermostat_story.ts";
import { thermostatStoryboard } from "../story/thermostat_storyboard.ts";
import { isAccepted, type Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceVideo } from "./produce_video.ts";
import type { Job } from "./render_plan.ts";
import type { LoadedFont } from "./produce_screenshot.ts";
import { assembleTailPlate } from "./trailer_plate.ts";

export const TRAILER_FILE = "trailer.json";

export type TrailerJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly story: ThermostatStory;
  readonly fonts: { readonly sans: LoadedFont; readonly mono: LoadedFont };
  readonly platesRoot: string;
  readonly outputRoot: string;
};

export type TrailerResult = { readonly video: Manifest; readonly thumbnail: { readonly file: string | null; readonly findings: readonly Finding[] } };

export async function produceTrailer(request: TrailerJob): Promise<Outcome<TrailerResult>> {
  const { toolbox, job, story, fonts } = request;
  if (job.slot.kind !== "trailer") {
    return { ok: false, error: `${job.slot.id} is not a trailer slot` };
  }
  const program = story.program[job.language];
  const id = `thermostat-${job.language}`;
  const directory = toolbox.files.join(request.outputRoot, job.directory);
  await toolbox.files.ensureDirectory(directory);
  const layout = thermostatLayout({ canvas: { width: job.slot.width, height: job.slot.height }, lines: program.lines, closing: program.outputs.at(-1) ?? "",
    measure: { mono: (text, size) => textWidth(fonts.mono.advances, text, size), sans: (text, size) => textWidth(fonts.sans.advances, text, size) } });
  const tail = await assembleTailPlate(toolbox, { root: request.platesRoot, tail: story.interface, language: job.language, slot: job.slot,
    output: toolbox.files.join(directory, "interface-source.mp4"), name: id });
  if (!tail.ok) {
    return tail;
  }
  const findings = [
    ...tail.value.findings,
    ...layout.overflow.map((line) => finding("TEXT-FIT", id, `"${line}" does not fit beside the values`)),
    ...auditContrast(thermostatContrastPairs()),
    ...auditLabels(request.catalog, job.slot, [{ kind: "title", language: job.language, text: story.title[job.language] }]),
  ];
  const limit = story.trace.at(-1)?.values[0] ?? 0;
  const composition = buildThermostatTrailer({ id, slot: job.slot, story, program, layout, limit });
  const assets = [{ name: SANS_FONT_FILE, bytes: fonts.sans.bytes }, { name: MONO_FONT_FILE, bytes: fonts.mono.bytes }, ...(tail.value.asset ? [tail.value.asset] : [])];
  const video = await produceVideo({ toolbox, catalog: request.catalog, job, composition, storyboard: thermostatStoryboard(story), voice: MILESTONE_VOICE, assets, findings, outputRoot: request.outputRoot });
  if (!video.ok) {
    return video;
  }
  const thumbnail = await produceThumbnail(request, { video: video.value, directory, id });
  await toolbox.files.writeText(toolbox.files.join(directory, TRAILER_FILE), `${JSON.stringify({ locales: job.locales, title: story.title[job.language], video: video.value.file, thumbnail: thumbnail.file }, null, 2)}\n`);
  return { ok: true, value: { video: video.value, thumbnail } };
}

async function produceThumbnail(request: TrailerJob, context: { video: Manifest; directory: string; id: string }): Promise<TrailerResult["thumbnail"]> {
  const slot = request.catalog.slots.find((entry) => entry.kind === "trailer-thumbnail");
  const { video, directory, id } = context;
  if (!slot || !video.file || !isAccepted(video)) {
    return { file: null, findings: [] };
  }
  const { files, media } = request.toolbox;
  const outputPath = files.join(directory, `${id}-thumbnail.png`);
  const fps = request.job.slot.video?.fps ?? 30;
  const still = await media.extractStill({ videoPath: video.file, frameIndex: Math.round(request.story.thumbnailSeconds * fps), longSide: null, outputPath });
  if (!still.ok) {
    return { file: null, findings: [finding("MEDIA-FORMAT", `${id}-thumbnail`, still.error)] };
  }
  return { file: outputPath, findings: auditImage({ slot, target: `${id}-thumbnail`, bytes: await files.readBytes(outputPath) }) };
}
