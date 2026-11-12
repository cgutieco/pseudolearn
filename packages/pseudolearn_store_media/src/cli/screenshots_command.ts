import { join, resolve } from "node:path";
import { isAccepted } from "../pipeline/manifest.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { produceScreenshotSet, type ScreenshotResult } from "../pipeline/screenshot_set.ts";
import { loadScreenshotStory } from "../pipeline/story_source.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/app-store-screenshots.json";
const DEFAULT_PLATES = "../../apps/pseudolearn_app/build/store-plates";
const FONTS = {
  sans: "../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf",
  mono: "../pseudolearn_brand/assets/fonts/IBMPlexMono-Medium.ttf",
};

export async function runScreenshots(context: CommandContext): Promise<number> {
  const storyPath = resolve(context.packageRoot, context.story ?? DEFAULT_STORY);
  const files = nodeFileStore();
  const story = await loadScreenshotStory(files, storyPath);
  if (!story.ok) {
    story.errors.forEach((error) => context.write(`${error.path}: ${error.message}`));
    return 1;
  }
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  const jobs = context.slotIds.length > 0 ? plan.jobs : plan.jobs.filter((job) => job.slot.device !== null);
  if (plan.unknownSlots.length > 0) {
    context.write(`unknown slots: ${plan.unknownSlots.join(", ")}`);
    return 2;
  }
  const outcome = await produceScreenshotSet({
    toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files },
    catalog: context.catalog,
    jobs,
    story: story.value,
    fontPaths: { sans: resolve(context.packageRoot, FONTS.sans), mono: resolve(context.packageRoot, FONTS.mono) },
    platesRoot: resolve(context.packageRoot, context.plates ?? DEFAULT_PLATES),
    outputRoot: join(context.packageRoot, "build", "screenshots", story.value.id),
    guides: context.guides,
  });
  if (!outcome.ok) {
    context.write(outcome.error);
    return 2;
  }
  return reportScreenshots(context, outcome.value);
}

function reportScreenshots(context: CommandContext, results: readonly ScreenshotResult[]): number {
  let failures = 0;
  for (const result of results) {
    const label = `${result.job.slot.id} ${result.job.language} ${result.chapter}`;
    if (!result.outcome.ok) {
      context.write(`${label}: ${result.outcome.error}`);
      failures += 1;
      continue;
    }
    const manifest = result.outcome.value;
    context.write(`${label}: ${manifest.file ?? "not rendered"} ${isAccepted(manifest) ? "accepted" : "rejected"}`);
    manifest.findings.forEach((entry) => context.write(`  ${entry.rule} ${entry.target}: ${entry.message}`));
    failures += isAccepted(manifest) ? 0 : 1;
  }
  return failures === 0 ? 0 : 1;
}
