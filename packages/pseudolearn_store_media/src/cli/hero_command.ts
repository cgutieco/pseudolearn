import { rm } from "node:fs/promises";
import { join, resolve } from "node:path";
import { loadLensStory } from "../pipeline/lens_source.ts";
import { isAccepted } from "../pipeline/manifest.ts";
import { HERO_KINDS, produceHero } from "../pipeline/produce_hero.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { loadFont } from "../pipeline/screenshot_set.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/app-store-creative.json";
const MONO_FONT = "../pseudolearn_brand/assets/fonts/IBMPlexMono-Medium.ttf";

export async function runHero(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const story = await loadLensStory(files, resolve(context.packageRoot, context.story ?? DEFAULT_STORY));
  const mono = await loadFont(files, resolve(context.packageRoot, MONO_FONT));
  if (!story.ok || !mono.ok) {
    (story.ok ? [] : story.errors).forEach((error) => context.write(`${error.path}: ${error.message}`));
    context.write(mono.ok ? "" : mono.error);
    return 1;
  }
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  const jobs = plan.jobs.filter((job) => HERO_KINDS.has(job.slot.kind));
  const outputRoot = join(context.packageRoot, "build", "hero", story.value.id);
  let failures = 0;
  for (const job of jobs) {
    const outcome = await produceHero({ toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files }, catalog: context.catalog, job, story: story.value, mono: mono.value.advances, outputRoot });
    await rm(join(outputRoot, job.directory, "frames"), { recursive: true, force: true });
    const label = `${job.slot.id} ${job.language}`;
    if (!outcome.ok) {
      context.write(`${label}: ${outcome.error}`);
      failures += 1;
      continue;
    }
    context.write(`${label}: ${outcome.value.file ?? "not rendered"} ${isAccepted(outcome.value) ? "accepted" : "rejected"}`);
    outcome.value.findings.forEach((entry) => context.write(`  ${entry.rule} ${entry.target}: ${entry.message}`));
    failures += isAccepted(outcome.value) ? 0 : 1;
  }
  return failures === 0 && jobs.length > 0 ? 0 : 1;
}
