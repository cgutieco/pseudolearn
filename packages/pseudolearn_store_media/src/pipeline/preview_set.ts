import type { Catalog } from "../catalog/catalog_types.ts";
import { PREVIEW_VOICE } from "../audio/score.ts";
import { readGlyphAdvances } from "../layout/glyph_advances.ts";
import type { PreviewStory } from "../story/preview_story.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { producePreview } from "./produce_preview.ts";
import type { Job } from "./render_plan.ts";

export type PreviewSetRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly jobs: readonly Job[];
  readonly story: PreviewStory;
  readonly fontPath: string;
  readonly platesRoot: string;
  readonly outputRoot: string;
};

export type PreviewResult = { readonly job: Job; readonly preview: string; readonly outcome: Outcome<Manifest> };

export async function producePreviewSet(request: PreviewSetRequest): Promise<Outcome<readonly PreviewResult[]>> {
  const notPreviews = request.jobs.filter((job) => job.slot.kind !== "app-preview").map((job) => job.slot.id);
  if (request.jobs.length === 0 || notPreviews.length > 0) {
    return { ok: false, error: `previews need app-preview slots${notPreviews.length > 0 ? `; not one: ${[...new Set(notPreviews)].join(", ")}` : ""}` };
  }
  const bytes = await request.toolbox.files.readBytesIfPresent(request.fontPath);
  const reading = bytes ? readGlyphAdvances(bytes) : null;
  if (!bytes || !reading?.ok) {
    return { ok: false, error: `cannot read the font ${request.fontPath}` };
  }
  const results: PreviewResult[] = [];
  for (const job of request.jobs) {
    for (const [index, preview] of request.story.previews.entries()) {
      const outcome = await producePreview({ ...request, job, preview, position: index + 1,
        frame: { brand: request.story.brand, disclosure: request.story.disclosure },
        font: { bytes, advances: reading.advances }, voice: PREVIEW_VOICE });
      results.push({ job, preview: preview.id, outcome });
    }
  }
  return { ok: true, value: results };
}
