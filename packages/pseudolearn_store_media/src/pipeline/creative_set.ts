import type { Catalog } from "../catalog/catalog_types.ts";
import type { LensStory } from "../story/lens_story.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceCreative } from "./produce_creative.ts";
import type { Job } from "./render_plan.ts";
import { loadFont } from "./screenshot_set.ts";

export const CREATIVE_KINDS = new Set(["header-video", "search-video", "universal-image"]);

export type CreativeSetRequest = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly jobs: readonly Job[];
  readonly story: LensStory;
  readonly fontPaths: { readonly sans: string; readonly mono: string };
  readonly outputRoot: string;
};

export type CreativeResult = { readonly job: Job; readonly outcome: Outcome<Manifest> };

export async function produceCreativeSet(request: CreativeSetRequest): Promise<Outcome<readonly CreativeResult[]>> {
  const foreign = request.jobs.filter((job) => !CREATIVE_KINDS.has(job.slot.kind)).map((job) => job.slot.id);
  if (foreign.length > 0) {
    return { ok: false, error: `creative assets need header, search or universal slots; not one: ${[...new Set(foreign)].join(", ")}` };
  }
  const sans = await loadFont(request.toolbox.files, request.fontPaths.sans);
  const mono = await loadFont(request.toolbox.files, request.fontPaths.mono);
  if (!sans.ok || !mono.ok) {
    return { ok: false, error: [sans, mono].map((font) => (font.ok ? "" : font.error)).filter(Boolean).join("; ") };
  }
  const results: CreativeResult[] = [];
  for (const job of request.jobs) {
    const outcome = await produceCreative({ ...request, job, fonts: { sans: sans.value, mono: mono.value } });
    results.push({ job, outcome });
  }
  return { ok: true, value: results };
}
