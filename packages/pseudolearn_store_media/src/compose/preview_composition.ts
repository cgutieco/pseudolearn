import type { Language } from "../catalog/catalog_types.ts";
import type { HeadlineFit, MeasureText } from "../layout/headline_fit.ts";
import { placeBrandCard } from "../layout/brand_card_layout.ts";
import { placePill } from "../layout/pin_layout.ts";
import type { Size } from "../layout/pixel_rect.ts";
import { placeCaption, type PixelInsets } from "../layout/preview_layout.ts";
import { plainLines } from "../story/headline_runs.ts";
import type { PlateFrame } from "../story/plate_timeline.ts";
import { plateSecondsAt, type BrandCard, type PlacedScene, type PreviewPlan, type Timed } from "../story/preview_plan.ts";
import type { PreviewPin } from "../story/preview_overlays.ts";
import { brandCardLines, brandCardMarkup, lockupAspect } from "./brand_card_markup.ts";
import { htmlDocument, type Composition } from "./composition.ts";
import { SANS_FONT_FILE } from "./editorial_markup.ts";
import { EDITORIAL_PALETTES } from "./editorial_palette.ts";
import * as markup from "./preview_markup.ts";

export type PreviewCompositionRequest = {
  readonly id: string;
  readonly plan: PreviewPlan;
  readonly canvas: Size;
  readonly insets: PixelInsets;
  readonly language: Language;
  readonly measure: MeasureText;
};

export type TimedCover = { readonly startSeconds: number; readonly endSeconds: number; readonly areaFraction: number };
export type TimedText = { readonly text: string; readonly fontSize: number; readonly startSeconds: number; readonly endSeconds: number; readonly sceneIndex: number };

export type PreviewComposition = Composition & {
  readonly plates: readonly { readonly sceneIndex: number; readonly file: string }[];
  readonly covers: readonly TimedCover[];
  readonly timedTexts: readonly TimedText[];
  readonly fits: readonly { readonly role: string; readonly fit: HeadlineFit }[];
  readonly missingFocus: readonly string[];
};

export const PIN_FONT_SHARE = 0.034;
export const TOUCH_DIAMETER_SHARE = 0.11;

type Parts = { body: string[]; lines: string[]; covers: TimedCover[]; texts: TimedText[]; fits: { role: string; fit: HeadlineFit }[]; missing: string[] };

export function buildPreviewComposition(request: PreviewCompositionRequest): PreviewComposition {
  const { plan, canvas } = request;
  const parts: Parts = { body: [], lines: [], covers: [], texts: [], fits: [], missing: [] };
  plan.scenes.forEach((placed) => addScene(parts, placed, canvas));
  plan.captions.forEach((timed, index) => addCaption(request, parts, { timed, index }));
  plan.pins.forEach((timed, index) => addPin(request, parts, { timed, index }));
  plan.cards.forEach((timed) => addCard(request, parts, timed));
  plan.touches.forEach((timed, index) => {
    parts.body.push(markup.touchMarkup(`touch-${index}`, timed.item, Math.min(canvas.width, canvas.height) * TOUCH_DIAMETER_SHARE));
    parts.lines.push(...markup.touchLines(`touch-${index}`, { start: timed.startSeconds, end: timed.endSeconds }));
  });
  const html = htmlDocument({ id: request.id, canvas, durationSeconds: plan.durationSeconds, style: markup.previewStyle(SANS_FONT_FILE),
    body: parts.body.join("\n"), timeline: parts.lines.join("\n") });
  return {
    id: request.id, canvas, durationSeconds: plan.durationSeconds, html, layout: [],
    texts: parts.texts.map((text) => text.text),
    plates: plan.scenes.map((placed) => ({ sceneIndex: placed.index, file: plateFileOf(placed.index) })),
    covers: parts.covers, timedTexts: parts.texts, fits: parts.fits, missingFocus: parts.missing,
  };
}

export function plateFileOf(sceneIndex: number): string {
  return `plates/scene-${sceneIndex}.mp4`;
}

function addScene(parts: Parts, placed: PlacedScene, canvas: Size): void {
  const id = `scene-${placed.index}`;
  parts.body.push(markup.plateMarkup(id, { src: plateFileOf(placed.index), start: placed.startSeconds,
    duration: placed.endSeconds - placed.startSeconds, mediaStart: placed.scene.fromSeconds, size: canvas }));
  if (placed.dissolveSeconds > 0) {
    parts.lines.push(markup.dissolveLine(id, { start: placed.startSeconds, seconds: placed.dissolveSeconds }));
  }
}

function addCaption(request: PreviewCompositionRequest, parts: Parts, entry: { timed: PreviewPlan["captions"][number]; index: number }): void {
  const { timed, index } = entry;
  const text = timed.item.text[request.language];
  const placed = placeCaption({ canvas: request.canvas, insets: request.insets, role: timed.item.role, lines: plainLines(text),
    anchor: timed.item.anchor }, request.measure);
  const palette = EDITORIAL_PALETTES[request.plan.scenes[timed.sceneIndex]?.scene.palette ?? "paper"];
  const id = `caption-${index}`;
  parts.body.push(markup.captionMarkup(id, text, placed, palette));
  parts.lines.push(...markup.fadeLines(id, { start: timed.startSeconds, end: timed.endSeconds }));
  parts.covers.push({ startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, areaFraction: placed.coverFraction });
  parts.texts.push({ text, fontSize: placed.fit.fontSize, startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, sceneIndex: timed.sceneIndex });
  parts.fits.push({ role: `${id} ${timed.item.role}`, fit: placed.fit });
}

function addPin(request: PreviewCompositionRequest, parts: Parts, entry: { timed: Timed<PreviewPin>; index: number }): void {
  const { timed, index } = entry;
  const placed = request.plan.scenes[timed.sceneIndex];
  const focus = placed ? frameAt(placed, timed.startSeconds)?.focus.find((rect) => rect.key === timed.item.focus) : undefined;
  if (!placed || !focus) {
    parts.missing.push(timed.item.focus);
    return;
  }
  const { canvas, insets } = request;
  const fontSize = Math.min(canvas.width, canvas.height) * PIN_FONT_SHARE;
  const text = timed.item.note[request.language].replaceAll("*", "");
  const point = { x: focus.x + focus.width * timed.item.pin.x, y: focus.y + focus.height * timed.item.pin.y };
  const safe = { x: insets.left, y: insets.top, width: canvas.width - insets.left - insets.right, height: canvas.height - insets.top - insets.bottom };
  const pill = placePill({ pin: point, size: { width: request.measure(text, fontSize) + fontSize * 1.6, height: fontSize * 2 }, safe, avoid: focus });
  const id = `pin-${index}`;
  parts.body.push(markup.pinOverlayMarkup(id, { point, pill, fontSize, text }, EDITORIAL_PALETTES[placed.scene.palette]));
  parts.lines.push(...markup.fadeLines(id, { start: timed.startSeconds, end: timed.endSeconds }));
  parts.covers.push({ startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, areaFraction: (pill.width * pill.height) / (canvas.width * canvas.height) });
  parts.texts.push({ text, fontSize, startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, sceneIndex: timed.sceneIndex });
}

function frameAt(placed: PlacedScene, seconds: number): PlateFrame | undefined {
  const frame = Math.floor(plateSecondsAt(placed, seconds) * placed.timeline.fps);
  return placed.timeline.frames[Math.min(Math.max(frame, 0), placed.timeline.frames.length - 1)];
}

function addCard(request: PreviewCompositionRequest, parts: Parts, timed: Timed<BrandCard>): void {
  const lines = timed.item.disclosure ? timed.item.disclosure[request.language].split("\n") : [];
  const placed = placeBrandCard({ canvas: request.canvas, insets: request.insets, kind: timed.item.kind, lockupAspect: lockupAspect(), lines }, request.measure);
  const id = `card-${timed.item.kind}`;
  parts.body.push(brandCardMarkup(id, placed, lines));
  parts.lines.push(...brandCardLines(id, { start: timed.startSeconds, end: timed.endSeconds, opening: timed.item.kind === "opening" }));
  parts.covers.push({ startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, areaFraction: placed.coverFraction });
  if (placed.fit) {
    parts.texts.push({ text: lines.join("\n"), fontSize: placed.fit.fontSize, startSeconds: timed.startSeconds, endSeconds: timed.endSeconds, sceneIndex: timed.sceneIndex });
    parts.fits.push({ role: `${id} disclosure`, fit: placed.fit });
  }
}
