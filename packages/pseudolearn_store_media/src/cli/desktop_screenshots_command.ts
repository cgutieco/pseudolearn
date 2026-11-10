import { rm } from "node:fs/promises";
import { join, resolve } from "node:path";
import { produceDesktopScreenshotSet, type DesktopResult } from "../pipeline/desktop_screenshot_set.ts";
import { loadLensStory } from "../pipeline/lens_source.ts";
import { isAccepted } from "../pipeline/manifest.ts";
import { planJobs } from "../pipeline/render_plan.ts";
import { loadFont } from "../pipeline/screenshot_set.ts";
import { loadDesktopStory } from "../pipeline/story_source.ts";
import { ffmpegToolkit } from "../render/ffmpeg_toolkit.ts";
import { hyperframesRenderer } from "../render/hyperframes_renderer.ts";
import { nodeFileStore } from "../render/node_file_store.ts";
import type { CommandContext } from "./main.ts";

const DEFAULT_STORY = "stories/microsoft-store-screenshots.json";
const TEXTURE_STORY = "stories/app-store-creative.json";
const DEFAULT_PLATES = "../../apps/pseudolearn_app/build/store-plates";
const MONO_FONT = "../pseudolearn_brand/assets/fonts/IBMPlexMono-Medium.ttf";
const SLOT = "microsoft.desktop.screenshot";

export async function runDesktopScreenshots(context: CommandContext): Promise<number> {
  const files = nodeFileStore();
  const story = await loadDesktopStory(files, resolve(context.packageRoot, context.story ?? DEFAULT_STORY));
  const texture = await loadLensStory(files, resolve(context.packageRoot, TEXTURE_STORY));
  const mono = await loadFont(files, resolve(context.packageRoot, MONO_FONT));
  if (!story.ok || !texture.ok || !mono.ok) {
    [story, texture].forEach((parsed) => (parsed.ok ? [] : parsed.errors).forEach((error) => context.write(`${error.path}: ${error.message}`)));
    context.write(mono.ok ? "" : mono.error);
    return 1;
  }
  const plan = planJobs({ catalog: context.catalog, slotIds: [SLOT], languages: context.languages });
  const outputRoot = join(context.packageRoot, "build", "screenshots", story.value.id);
  const outcome = await produceDesktopScreenshotSet({
    toolbox: { frames: hyperframesRenderer(), media: ffmpegToolkit(), files },
    catalog: context.catalog, jobs: plan.jobs, story: story.value, statements: texture.value.statements, mono: mono.value.advances,
    platesRoot: resolve(context.packageRoot, context.plates ?? DEFAULT_PLATES), outputRoot,
  });
  for (const job of plan.jobs) {
    await rm(join(outputRoot, job.directory, "frames"), { recursive: true, force: true });
  }
  if (!outcome.ok) {
    context.write(outcome.error);
    return 2;
  }
  return reportDesktop(context, outcome.value);
}

function reportDesktop(context: CommandContext, results: readonly DesktopResult[]): number {
  let failures = 0;
  for (const result of results) {
    const label = `${result.job.slot.id} ${result.job.language} ${result.shot}`;
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
