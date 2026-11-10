import { join, resolve } from "node:path";
import { isAccepted } from "../pipeline/manifest.ts";
import { producePreviewSet, type PreviewResult } from "../pipeline/preview_set.ts";
import { loadPreviewStory } from "../pipeline/preview_source.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/app-store-previews.json";
const DEFAULT_PLATES = "../../apps/pseudolearn_app/build/store-previews";
const SANS_FONT = "../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf";

export async function runPreviews(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const story = await loadPreviewStory(files, resolve(context.packageRoot, context.story ?? DEFAULT_STORY));
  if (!story.ok) {
    story.errors.forEach((error) => context.write(`${error.path}: ${error.message}`));
    return 1;
  }
  const plan = planJobs({ catalog: context.catalog, slotIds: context.slotIds, languages: context.languages });
  if (plan.unknownSlots.length > 0) {
    context.write(`unknown slots: ${plan.unknownSlots.join(", ")}`);
    return 2;
  }
  const outcome = await producePreviewSet({
    toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files },
    catalog: context.catalog,
    jobs: context.slotIds.length > 0 ? plan.jobs : plan.jobs.filter((job) => job.slot.kind === "app-preview"),
    story: story.value,
    fontPath: resolve(context.packageRoot, SANS_FONT),
    platesRoot: resolve(context.packageRoot, context.plates ?? DEFAULT_PLATES),
    outputRoot: join(context.packageRoot, "build", "previews", story.value.id),
  });
  if (!outcome.ok) {
    context.write(outcome.error);
    return 2;
  }
  return reportPreviews(context, outcome.value);
}

function reportPreviews(context: CommandContext, results: readonly PreviewResult[]): number {
  let failures = 0;
  for (const result of results) {
    const label = `${result.job.slot.id} ${result.job.language} ${result.preview}`;
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
