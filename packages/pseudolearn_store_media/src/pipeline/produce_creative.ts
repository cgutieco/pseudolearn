import type { Catalog } from "../catalog/catalog_types.ts";
import { PREVIEW_VOICE } from "../audio/score.ts";
import type { Finding } from "../audit/finding.ts";
import { auditLensLabels, auditLensRows } from "../audit/lens_audit.ts";
import { auditContrast } from "../audit/text_audit.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "../compose/editorial_markup.ts";
import { buildLensComposition, type LensPiece } from "../compose/lens_composition.ts";
import { lensContrastPairs } from "../compose/lens_palette.ts";
import { textWidth } from "../layout/glyph_advances.ts";
import type { LensStory } from "../story/lens_story.ts";
import { lensStoryboard } from "./lens_storyboard.ts";
import type { Manifest } from "./manifest.ts";
import type { Outcome, Toolbox } from "./ports.ts";
import { produceLensStill } from "./produce_lens_still.ts";
import type { LoadedFont } from "./produce_screenshot.ts";
import { produceVideo, type ProjectAsset } from "./produce_video.ts";
import type { Job } from "./render_plan.ts";

export type CreativeJob = {
  readonly toolbox: Toolbox;
  readonly catalog: Catalog;
  readonly job: Job;
  readonly story: LensStory;
  readonly fonts: { readonly sans: LoadedFont; readonly mono: LoadedFont };
  readonly outputRoot: string;
};

export function produceCreative(request: CreativeJob): Promise<Outcome<Manifest>> {
  const { job, story, fonts } = request;
  const piece = buildLensComposition({ slot: job.slot, story, language: job.language, measure: {
    mono: (text, size) => textWidth(fonts.mono.advances, text, size),
    sans: (text, size) => textWidth(fonts.sans.advances, text, size),
  } });
  const assets: readonly ProjectAsset[] = [{ name: SANS_FONT_FILE, bytes: fonts.sans.bytes }, { name: MONO_FONT_FILE, bytes: fonts.mono.bytes }];
  const findings = designFindings(request, piece);
  if (!job.slot.video || findings.length > 0) {
    return produceLensStill({ ...request, composition: piece.composition, assets, findings });
  }
  const kinds = story.statements[job.language].map((statement) => statement.kind);
  return produceVideo({ toolbox: request.toolbox, catalog: request.catalog, job, composition: piece.composition,
    storyboard: lensStoryboard(piece.layout, story, kinds), voice: PREVIEW_VOICE, assets, outputRoot: request.outputRoot });
}

function designFindings(request: CreativeJob, piece: LensPiece): readonly Finding[] {
  const target = piece.composition.id;
  const sans = (text: string, size: number) => textWidth(request.fonts.sans.advances, text, size);
  return [...auditLensRows(target, piece.layout), ...auditLensLabels(target, piece.layout, sans), ...auditContrast(lensContrastPairs())];
}
