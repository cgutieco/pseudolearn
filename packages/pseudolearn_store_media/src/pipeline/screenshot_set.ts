import type { Catalog } from "../catalog/catalog_types.ts";
import { readGlyphAdvances } from "../layout/glyph_advances.ts";
import type { ScreenshotStory } from "../story/screenshot_story.ts";
import type { Manifest } from "./manifest.ts";
import type { FileStore, Outcome, Toolbox } from "./ports.ts";
import { produceScreenshot, type LoadedFont } from "./produce_screenshot.ts";
import type { Job } from "./render_plan.ts";

export type ScreenshotSetRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly jobs: readonly Job[];
  readonly story: ScreenshotStory;
  readonly fontPaths: { readonly sans: string; readonly mono: string };
  readonly platesRoot: string;
  readonly outputRoot: string;
  readonly guides: boolean;
};

export type ScreenshotResult = { readonly job: Job; readonly chapter: string; readonly outcome: Outcome<Manifest> };

export async function produceScreenshotSet(request: ScreenshotSetRequest): Promise<Outcome<readonly ScreenshotResult[]>> {
  const problem = setProblem(request);
  if (problem) {
    return { ok: false, error: problem };
  }
  const sans = await loadFont(request.toolbox.files, request.fontPaths.sans);
  const mono = await loadFont(request.toolbox.files, request.fontPaths.mono);
  if (!sans.ok || !mono.ok) {
    return { ok: false, error: [sans, mono].map((font) => (font.ok ? "" : font.error)).filter(Boolean).join("; ") };
  }
  const results: ScreenshotResult[] = [];
  for (const job of request.jobs) {
    for (const [index, chapter] of request.story.chapters.entries()) {
      const outcome = await produceScreenshot({ ...request, job, chapter, position: index + 1, fonts: { sans: sans.value, mono: mono.value } });
      results.push({ job, chapter: chapter.id, outcome });
    }
  }
  return { ok: true, value: results };
}

function setProblem(request: ScreenshotSetRequest): string | null {
  const notScreenshots = request.jobs.filter((job) => job.slot.kind !== "screenshot").map((job) => job.slot.id);
  if (request.jobs.length === 0 || notScreenshots.length > 0) {
    return `screenshots need screenshot slots${notScreenshots.length > 0 ? `; not one: ${[...new Set(notScreenshots)].join(", ")}` : ""}`;
  }
  const tooMany = request.jobs.find((job) => request.story.chapters.length > job.slot.maxCount);
  return tooMany ? `${request.story.chapters.length} chapters exceed the ${tooMany.slot.maxCount} images ${tooMany.slot.id} allows` : null;
}

export async function loadFont(files: FileStore, path: string): Promise<Outcome<LoadedFont>> {
  const bytes = await files.readBytesIfPresent(path);
  if (!bytes) {
    return { ok: false, error: `missing font ${path}` };
  }
  const reading = readGlyphAdvances(bytes);
  return reading.ok ? { ok: true, value: { bytes, advances: reading.advances } } : { ok: false, error: `${path}: ${reading.reason}` };
}
