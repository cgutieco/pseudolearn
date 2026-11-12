import type { Catalog } from "../catalog/catalog_types.ts";
import { buildMuteLens } from "../compose/mute_lens.ts";
import { textWidth, type GlyphAdvances } from "../layout/glyph_advances.ts";
import { muteLensLayout } from "../layout/mute_lens_layout.ts";
import { toPixels } from "../layout/pixel_rect.ts";
import type { LensStory } from "../story/lens_story.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceStill } from "./produce_still.ts";
import type { Job } from "./render_plan.ts";

export const HERO_KINDS = new Set(["hero-art", "poster-art", "box-art"]);

export type HeroJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly story: LensStory;
  readonly mono: GlyphAdvances;
  readonly outputRoot: string;
};

export function produceHero(request: HeroJob): Promise<Outcome<Manifest>> {
  const { job, story } = request;
  if (!HERO_KINDS.has(job.slot.kind)) {
    return Promise.resolve({ ok: false, error: `${job.slot.id} is not hero, poster or box art` });
  }
  const statements = story.statements[job.language];
  const canvas = { width: job.slot.width, height: job.slot.height };
  const layout = muteLensLayout({
    canvas,
    safeArea: toPixels(job.slot.safeArea, canvas),
    lines: statements.map((statement) => statement.text),
    anchor: Math.max(0, statements.findIndex((statement) => statement.kind === "decision")),
    measure: (text, size) => textWidth(request.mono, text, size),
  });
  const id = `mute-lens-${job.slot.kind}-${job.language}`;
  const composition = buildMuteLens({ id, slot: job.slot, layout, kinds: statements.map((statement) => statement.kind) });
  return produceStill({ toolbox: request.toolbox, catalog: request.catalog, job, composition, assets: [], findings: [], outputRoot: request.outputRoot });
}
