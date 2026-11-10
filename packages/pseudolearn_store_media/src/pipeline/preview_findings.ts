import type { Catalog, Slot } from "../catalog/catalog_types.ts";
import { auditAppUi } from "../audit/app_ui_audit.ts";
import { finding, type Finding } from "../audit/finding.ts";
import { auditPoster } from "../audit/poster_audit.ts";
import { auditReadingTime, auditSceneSpans } from "../audit/preview_timing_audit.ts";
import { auditHeadlineFit } from "../audit/screenshot_audit.ts";
import { auditContrast, auditLexicon } from "../audit/text_audit.ts";
import { CARD_GROUND, CARD_INK } from "../compose/brand_card_markup.ts";
import { EDITORIAL_PALETTES, editorialContrastPairs } from "../compose/editorial_palette.ts";
import type { PreviewComposition } from "../compose/preview_composition.ts";
import type { PreviewPlan } from "../story/preview_plan.ts";
import { previewStoryboard } from "../story/preview_plan.ts";
import { storyboardProblems } from "../story/storyboard.ts";

export type PreviewCheck = { readonly catalog: Catalog; readonly slot: Slot; readonly plan: PreviewPlan; readonly composition: PreviewComposition };

const PREVIEW_ROLES = new Set(["headline", "marked headline", "note"]);

export function previewFindings(check: PreviewCheck): readonly Finding[] {
  const { catalog, slot, plan, composition } = check;
  const target = composition.id;
  return [
    ...storyboardProblems(previewStoryboard(plan), slot).map((problem) => finding("MEDIA-DURATION", target, problem)),
    ...plateFindings(check),
    ...auditSceneSpans(plan.scenes.map((placed) => ({
      label: `${target} scene ${placed.index} ${placed.scene.plate}`, startSeconds: placed.startSeconds, endSeconds: placed.endSeconds,
      dissolveSeconds: placed.dissolveSeconds, trimEndSeconds: placed.scene.toSeconds, plateSeconds: placed.timeline.frames.length / placed.timeline.fps,
    }))),
    ...auditReadingTime(composition.timedTexts.map((text) => ({ ...text,
      sceneStartSeconds: plan.scenes[text.sceneIndex]?.startSeconds ?? 0, sceneEndSeconds: plan.scenes[text.sceneIndex]?.endSeconds ?? 0 }))),
    ...auditAppUi({ target, durationSeconds: plan.durationSeconds, fps: slot.video?.fps ?? 30, scenes: plan.scenes, covers: composition.covers }),
    ...posterFindings(check),
    ...auditLexicon(catalog, slot.store, composition.texts),
    ...auditContrast([...new Set(plan.scenes.map((placed) => placed.scene.palette))].flatMap((id) =>
      editorialContrastPairs(EDITORIAL_PALETTES[id]).filter((pair) => PREVIEW_ROLES.has(pair.role)).map((pair) => ({ ...pair, role: `${id} ${pair.role}` })))),
    ...auditContrast(plan.cards.length > 0 ? [{ role: "brand card disclosure", foreground: CARD_INK, background: CARD_GROUND }] : []),
    ...disclosureFindings(check),
    ...composition.fits.flatMap((entry) => auditHeadlineFit(`${target} ${entry.role}`, entry.fit)),
  ];
}

function plateFindings(check: PreviewCheck): readonly Finding[] {
  const { slot, plan, composition } = check;
  const sized = plan.scenes
    .filter((placed) => placed.timeline.pixelWidth !== slot.width || placed.timeline.pixelHeight !== slot.height)
    .map((placed) => finding("MEDIA-PLATE", placed.scene.plate,
      `recorded at ${placed.timeline.pixelWidth}×${placed.timeline.pixelHeight}, so it would be scaled into ${slot.width}×${slot.height}`));
  const focus = composition.missingFocus.map((key) => finding("MEDIA-PLATE", composition.id, `the plate did not record the ${key} the pin points at`));
  return [...sized, ...focus];
}

function posterFindings(check: PreviewCheck): readonly Finding[] {
  const { slot, plan, composition } = check;
  const at = plan.posterSeconds;
  return auditPoster({
    target: composition.id, posterSeconds: at, durationSeconds: plan.durationSeconds, fps: slot.video?.fps ?? 30,
    transitions: plan.scenes.filter((placed) => placed.dissolveSeconds > 0)
      .map((placed) => ({ startSeconds: placed.startSeconds, endSeconds: placed.startSeconds + placed.dissolveSeconds })),
    texts: composition.timedTexts.filter((text) => at >= text.startSeconds && at < text.endSeconds),
    canvasLongSide: Math.max(slot.width, slot.height),
  });
}

function disclosureFindings(check: PreviewCheck): readonly Finding[] {
  const { plan, composition } = check;
  const disclosed = plan.cards.some((card) => card.item.disclosure !== null) || plan.captions.some((caption) => caption.item.role === "disclosure");
  return plan.needsDisclosure && !disclosed
    ? [finding("MEDIA-DISCLOSURE", composition.id, "shows a feature that needs sign-in or a purchase without saying so")]
    : [];
}
