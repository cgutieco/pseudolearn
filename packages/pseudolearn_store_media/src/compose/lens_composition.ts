import type { Language, Slot } from "../catalog/catalog_types.ts";
import { sampleEveryFrame } from "../layout/frame_sampling.ts";
import { stillMoment } from "../layout/lens_crossings.ts";
import { lensLayout, type LensLayout, type NodeForm, type TextMeasure } from "../layout/lens_layout.ts";
import type { FrameLayout } from "../layout/safe_area_check.ts";
import type { LensStory, StatementKind } from "../story/lens_story.ts";
import { frozenClockTimeline, htmlDocument, settingClockTimeline, type Composition } from "./composition.ts";
import { diagramMarkup, riverMarkup } from "./lens_markup.ts";
import { lensScript, lensStyle } from "./lens_style.ts";

export type LensCompositionRequest = {
  readonly slot: Slot;
  readonly story: LensStory;
  readonly language: Language;
  readonly measure: TextMeasure;
};

export type LensPiece = { readonly composition: Composition; readonly layout: LensLayout };

const FORMS: Readonly<Record<StatementKind, NodeForm>> = { terminal: "box", io: "box", process: "box", decision: "tall", join: "dot" };

export function buildLensComposition(request: LensCompositionRequest): LensPiece {
  const { slot, story, language } = request;
  const statements = story.statements[language];
  const layout = lensLayout({ slot, entries: statements.map((item) => ({ text: item.text, form: FORMS[item.kind] })), rhythm: story.rows, measure: request.measure });
  const still = slot.video === null;
  const durationSeconds = still ? 1 : story.durationSeconds;
  const id = `lens-${slot.id.replaceAll(".", "-")}-${language}`;
  const { lens } = layout;
  const body = `${riverMarkup(layout)}
<div id="lens" style="left:${lens.x}px;top:${lens.y}px;width:${lens.width}px;height:${lens.height}px"><div id="lens-inner">${diagramMarkup(layout, statements.map((item) => item.kind))}</div><div id="lens-rim"></div></div>
<script>${lensScript(layout, story.durationSeconds)}</script>`;
  const html = htmlDocument({ id, canvas: layout.canvas, durationSeconds, style: lensStyle(layout), body,
    timeline: still ? frozenClockTimeline(stillMoment(layout, story.durationSeconds, story.posterSeconds)) : settingClockTimeline(durationSeconds) });
  return { layout, composition: { id, canvas: layout.canvas, durationSeconds, html, layout: frames(slot, layout, durationSeconds), texts: statements.map((item) => item.text) } };
}

function frames(slot: Slot, layout: LensLayout, durationSeconds: number): readonly FrameLayout[] {
  const lens = [{ name: "lens", rect: layout.lens, essential: true }];
  return slot.video ? sampleEveryFrame({ durationSeconds, fps: slot.video.fps }, () => lens) : [{ timeSeconds: 0, elements: lens }];
}
