import { rm } from "node:fs/promises";
import { join, resolve } from "node:path";
import { isAccepted } from "../pipeline/manifest.ts";
import { produceTrailer } from "../pipeline/produce_trailer.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { loadFont } from "../pipeline/screenshot_set.ts";
import { loadThermostatStory } from "../pipeline/story_source.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/microsoft-store-trailer.json";
const DEFAULT_PLATES = "../../apps/pseudolearn_app/build/trailer-plates";
const FONTS = {
  sans: "../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf",
  mono: "../pseudolearn_brand/assets/fonts/IBMPlexMono-Medium.ttf",
};

export async function runTrailer(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const story = await loadThermostatStory(files, resolve(context.packageRoot, context.story ?? DEFAULT_STORY));
  const sans = await loadFont(files, resolve(context.packageRoot, FONTS.sans));
  const mono = await loadFont(files, resolve(context.packageRoot, FONTS.mono));
  if (!story.ok || !sans.ok || !mono.ok) {
    (story.ok ? [] : story.errors).forEach((error) => context.write(`${error.path}: ${error.message}`));
    [sans, mono].forEach((font) => context.write(font.ok ? "" : font.error));
    return 1;
  }
  const jobs = planJobs({ catalog: context.catalog, slotIds: ["microsoft.trailer"], languages: context.languages }).jobs;
  const outputRoot = join(context.packageRoot, "build", "trailer", story.value.id);
  let failures = 0;
  for (const job of jobs) {
    const outcome = await produceTrailer({ toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files }, catalog: context.catalog, job, story: story.value,
      fonts: { sans: sans.value, mono: mono.value }, platesRoot: resolve(context.packageRoot, context.plates ?? DEFAULT_PLATES), outputRoot });
    await rm(join(outputRoot, job.directory, "frames"), { recursive: true, force: true });
    failures += reportTrailer(context, `${job.slot.id} ${job.language}`, outcome);
  }
  return failures === 0 ? 0 : 1;
}

function reportTrailer(context: CommandContext, label: string, outcome: Awaited<ReturnType<typeof produceTrailer>>): number {
  if (!outcome.ok) {
    context.write(`${label}: ${outcome.error}`);
    return 1;
  }
  const { video, thumbnail } = outcome.value;
  const accepted = isAccepted(video) && thumbnail.file !== null && thumbnail.findings.length === 0;
  context.write(`${label}: ${video.file ?? "not rendered"} · ${thumbnail.file ?? "no thumbnail"} ${accepted ? "accepted" : "rejected"}`);
  [...video.findings, ...thumbnail.findings].forEach((entry) => context.write(`  ${entry.rule} ${entry.target}: ${entry.message}`));
  return accepted ? 0 : 1;
}
