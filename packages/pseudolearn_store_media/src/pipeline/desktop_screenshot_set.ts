import type { Catalog, Language } from "../catalog/catalog_types.ts";
import type { GlyphAdvances } from "../layout/glyph_advances.ts";
import type { DesktopStory } from "../story/desktop_story.ts";
import type { Statement } from "../story/lens_story.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceDesktopScreenshot } from "./produce_desktop_screenshot.ts";
import type { Job } from "./render_plan.ts";

export const CAPTIONS_FILE = "captions.json";

export type DesktopSetRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly jobs: readonly Job[];
  readonly story: DesktopStory;
  readonly statements: Readonly<Record<Language, readonly Statement[]>>;
  readonly mono: GlyphAdvances;
  readonly platesRoot: string;
  readonly outputRoot: string;
};

export type DesktopResult = { readonly job: Job; readonly shot: string; readonly outcome: Outcome<Manifest> };

export async function produceDesktopScreenshotSet(request: DesktopSetRequest): Promise<Outcome<readonly DesktopResult[]>> {
  const oversized = request.jobs.find((job) => request.story.shots.length > job.slot.maxCount);
  if (oversized) {
    return { ok: false, error: `${request.story.shots.length} screenshots exceed the ${oversized.slot.maxCount} that ${oversized.slot.id} takes` };
  }
  const results: DesktopResult[] = [];
  for (const job of request.jobs) {
    const lines = request.statements[job.language].map((statement) => statement.text);
    for (const [index, shot] of request.story.shots.entries()) {
      const outcome = await produceDesktopScreenshot({ ...request, job, shot, position: index + 1, texture: { lines, mono: request.mono } });
      results.push({ job, shot: shot.id, outcome });
    }
    await writeCaptions(request, job, results.filter((result) => result.job === job));
  }
  return { ok: true, value: results };
}

async function writeCaptions(request: DesktopSetRequest, job: Job, results: readonly DesktopResult[]): Promise<void> {
  const { files } = request.toolbox;
  const entries = results.map((result, index) => ({
    position: index + 1,
    file: result.outcome.ok ? result.outcome.value.file : null,
    caption: request.story.shots[index]?.caption[job.language] ?? "",
  }));
  const directory = files.join(request.outputRoot, job.directory);
  await files.ensureDirectory(directory);
  await files.writeText(files.join(directory, CAPTIONS_FILE), `${JSON.stringify({ locales: job.locales, screenshots: entries }, null, 2)}\n`);
}
