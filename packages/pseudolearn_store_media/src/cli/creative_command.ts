import { rm } from "node:fs/promises";
import { join, resolve } from "node:path";
import { CREATIVE_KINDS, produceCreativeSet, type CreativeResult } from "../pipeline/creative_set.ts";
import { loadLensStory } from "../pipeline/lens_source.ts";
import { isAccepted } from "../pipeline/manifest.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/app-store-creative.json";
const FONTS = {
  sans: "../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf",
  mono: "../pseudolearn_brand/assets/fonts/IBMPlexMono-Medium.ttf",
};

export async function runCreative(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const story = await loadLensStory(files, resolve(context.packageRoot, context.story ?? DEFAULT_STORY));
  if (!story.ok) {
    story.errors.forEach((error) => context.write(`${error.path}: ${error.message}`));
    return 1;
  }
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  if (plan.unknownSlots.length > 0) {
    context.write(`unknown slots: ${plan.unknownSlots.join(", ")}`);
    return 2;
  }
  const jobs = context.slotIds.length > 0 ? plan.jobs : plan.jobs.filter((job) => job.slot.store === "app-store" && CREATIVE_KINDS.has(job.slot.kind));
  const outputRoot = join(context.packageRoot, "build", "creative", story.value.id);
  const results: CreativeResult[] = [];
  for (const job of jobs) {
    const outcome = await produceCreativeSet({
      toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files },
      catalog: context.catalog,
      jobs: [job],
      story: story.value,
      fontPaths: { sans: resolve(context.packageRoot, FONTS.sans), mono: resolve(context.packageRoot, FONTS.mono) },
      outputRoot,
    });
    if (!outcome.ok) {
      context.write(outcome.error);
      return 2;
    }
    results.push(...outcome.value);
    await dropFrames(join(outputRoot, job.directory));
  }
  return reportCreative(context, results);
}

async function dropFrames(directory: string): Promise<void> {
  await rm(join(directory, "frames"), { recursive: true, force: true });
  await rm(join(directory, "review", "frames"), { recursive: true, force: true });
}

function reportCreative(context: CommandContext, results: readonly CreativeResult[]): number {
  let failures = 0;
  for (const result of results) {
    const label = `${result.job.slot.id} ${result.job.language}`;
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
