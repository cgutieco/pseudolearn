import type { Device, Language, Slot } from "../catalog/catalog_types.ts";
import { fitHeadline, type HeadlineFit, type MeasureText } from "../layout/headline_fit.ts";
import { editorialLayout, type EditorialLayout, type TextSizes } from "../layout/editorial_layout.ts";
import { plateToCanvas, placePill } from "../layout/pin_layout.ts";
import { toPixels, type PixelRect, type Size } from "../layout/pixel_rect.ts";
import type { PlacedElement } from "../layout/safe_area_check.ts";
import { headlineRuns, plainLines } from "../story/headline_runs.ts";
import type { Chapter } from "../story/screenshot_story.ts";
import { htmlDocument, type Composition } from "./composition.ts";
import { deviceMarkup } from "./device_markup.ts";
import * as markup from "./editorial_markup.ts";
import { EDITORIAL_PALETTES, editorialContrastPairs, type EditorialPalette } from "./editorial_palette.ts";
import { rectStyle } from "./html_text.ts";

export const PLATE_FILE = "plate.png";

export type Measures = { readonly sans: MeasureText; readonly mono: MeasureText };

export type EditorialRequest = {
  readonly slot: Slot;
  readonly device: Device;
  readonly chapter: Chapter;
  readonly position: number;
  readonly language: Language;
  readonly texture: readonly string[];
  readonly focus: PixelRect | null;
  readonly plate: Size;
  readonly measures: Measures;
  readonly guides: boolean;
};

export type RoleFit = { readonly role: string; readonly fit: HeadlineFit };

export type ScreenshotComposition = Composition & {
  readonly fits: readonly RoleFit[];
  readonly contrast: ReturnType<typeof editorialContrastPairs>;
};

type Piece = { readonly html: string; readonly elements: readonly PlacedElement[]; readonly fits: readonly RoleFit[]; readonly texts: readonly string[] };

export function buildEditorialScreenshot(request: EditorialRequest): ScreenshotComposition {
  const { slot, chapter, language } = request;
  const canvas = { width: slot.width, height: slot.height };
  const safe = toPixels(slot.safeArea, canvas);
  const layout = editorialLayout({ canvas, safe, device: request.device, kind: chapter.kind });
  const palette = EDITORIAL_PALETTES[chapter.palette];
  const headline = headlinePiece(request, layout, palette);
  const pieces = [devicePiece(request, { layout, palette, safe, avoid: headline.elements[0]?.rect ?? layout.headline }),
    headline, labelPiece(request, layout, palette), sublinePiece(request, layout, palette), codePiece(request, layout)];
  const guide = request.guides ? `<div style="${rectStyle(safe)}border:3px dashed ${palette.frame}"></div>` : "";
  const id = `${slot.id.replaceAll(".", "-")}-${chapter.id}-${language}`;
  return {
    id,
    canvas,
    durationSeconds: 1,
    html: htmlDocument({ id, canvas, durationSeconds: 1, style: markup.editorialStyle(canvas, palette), timeline: "",
      body: [markup.textureMarkup(request.texture, canvas, palette), ...pieces.map((piece) => piece.html), markup.grainMarkup(), guide].join("\n") }),
    layout: [{ timeSeconds: 0, elements: pieces.flatMap((piece) => piece.elements) }],
    texts: [...request.texture, ...pieces.flatMap((piece) => piece.texts)],
    fits: pieces.flatMap((piece) => piece.fits),
    contrast: editorialContrastPairs(palette),
  };
}

function fitted(lines: readonly string[], box: PixelRect, context: { sizes: TextSizes; lineHeight: number; measure: MeasureText }) {
  const fit = fitHeadline({ lines, boxWidth: box.width, boxHeight: box.height, maximumFontSize: context.sizes.maximum,
    minimumFontSize: context.sizes.minimum, lineHeight: context.lineHeight, measure: context.measure });
  const width = Math.max(0, ...lines.map((line) => context.measure(line, fit.fontSize)));
  return { fit, placed: { size: fit.fontSize, rect: { x: box.x, y: box.y, width, height: lines.length * fit.fontSize * context.lineHeight } } };
}

function headlinePiece(request: EditorialRequest, layout: EditorialLayout, palette: EditorialPalette): Piece {
  const text = request.chapter.headline[request.language];
  const lines = plainLines(text);
  const { fit, placed } = fitted(lines, layout.headline, { sizes: layout.headlineSizes, lineHeight: markup.HEADLINE_LINE_HEIGHT, measure: request.measures.sans });
  return { html: markup.headlineMarkup(headlineRuns(text) ?? [], placed, palette), elements: [{ name: "headline", rect: placed.rect, essential: true }],
    fits: [{ role: "headline", fit }], texts: [lines.join("\n")] };
}

function labelPiece(request: EditorialRequest, layout: EditorialLayout, palette: EditorialPalette): Piece {
  if (request.chapter.kind === "manifesto") {
    return { html: "", elements: [], fits: [], texts: [] };
  }
  const text = String(request.position).padStart(2, "0");
  const placed = { size: layout.label.size, rect: { x: layout.label.x, y: layout.label.y, width: request.measures.sans(text, layout.label.size) * 1.4, height: layout.label.size * 1.2 } };
  return { html: markup.labelMarkup(text, placed, palette), elements: [{ name: "label", rect: placed.rect, essential: true }], fits: [], texts: [] };
}

function sublinePiece(request: EditorialRequest, layout: EditorialLayout, palette: EditorialPalette): Piece {
  const text = request.chapter.subline?.[request.language];
  if (!text || !layout.subline) {
    return { html: "", elements: [], fits: [], texts: [] };
  }
  const lines = text.split("\n");
  const { fit, placed } = fitted(lines, layout.subline, { sizes: layout.sublineSizes, lineHeight: markup.MONO_LINE_HEIGHT, measure: request.measures.mono });
  return { html: markup.sublineMarkup(lines, placed, palette), elements: [{ name: "subline", rect: placed.rect, essential: true }],
    fits: [{ role: "subline", fit }], texts: [text] };
}

function codePiece(request: EditorialRequest, layout: EditorialLayout): Piece {
  const lines = request.chapter.code?.[request.language];
  if (!lines || !layout.code) {
    return { html: "", elements: [], fits: [], texts: [] };
  }
  const card = layout.code;
  const pad = Math.min(card.height, card.width) * 0.16;
  const inner = { x: card.x + pad, y: card.y + pad, width: card.width - 2 * pad, height: card.height - 2 * pad };
  const { fit, placed } = fitted(lines, inner, { sizes: layout.codeSizes, lineHeight: markup.MONO_LINE_HEIGHT, measure: request.measures.mono });
  const centered = { ...placed, rect: { ...placed.rect, y: inner.y + (inner.height - placed.rect.height) / 2 } };
  return { html: markup.codeCardMarkup(lines, card, centered), elements: [{ name: "code", rect: card, essential: true }],
    fits: [{ role: "code", fit }], texts: [lines.join("\n")] };
}

type DeviceContext = { readonly layout: EditorialLayout; readonly palette: EditorialPalette; readonly safe: PixelRect; readonly avoid: PixelRect };

function devicePiece(request: EditorialRequest, context: DeviceContext): Piece {
  const placement = context.layout.device;
  if (!placement) {
    return { html: "", elements: [], fits: [], texts: [] };
  }
  const canvasRect = { x: 0, y: 0, width: request.slot.width, height: request.slot.height };
  const frame = { name: "device", rect: clip(placement.outer, canvasRect), essential: false };
  const html = deviceMarkup({ device: request.device, placement, plateFile: PLATE_FILE });
  const note = request.chapter.note?.[request.language];
  const { focus, chapter } = request;
  if (!note || !focus || !chapter.pin) {
    return { html, elements: [frame], fits: [], texts: [] };
  }
  const mapped = plateToCanvas({ placement, plate: request.plate, focus, pin: chapter.pin }, request.device.fold);
  const size = context.layout.noteSize;
  const fit = fitHeadline({ lines: [note], boxWidth: context.safe.width - 1.6 * size, boxHeight: size * 2, maximumFontSize: size,
    minimumFontSize: size * 0.75, lineHeight: 1, measure: request.measures.sans });
  const pillSize = { width: request.measures.sans(note, fit.fontSize) + 1.6 * fit.fontSize, height: fit.fontSize * 2 };
  const pill = placePill({ pin: mapped.point, size: pillSize, safe: context.safe, avoid: context.avoid });
  const weight = Math.max(4, size * 0.13);
  return {
    html: `${html}\n${markup.highlightMarkup(mapped.highlight, context.palette, weight)}\n${markup.pinMarkup(mapped.point, { rect: pill, size: fit.fontSize, text: note }, context.palette)}`,
    elements: [frame, { name: "note", rect: pill, essential: true }],
    fits: [{ role: "note", fit }],
    texts: [note],
  };
}

function clip(rect: PixelRect, bounds: PixelRect): PixelRect {
  const x = Math.max(rect.x, bounds.x);
  const y = Math.max(rect.y, bounds.y);
  return { x, y, width: Math.max(0, Math.min(rect.x + rect.width, bounds.x + bounds.width) - x), height: Math.max(0, Math.min(rect.y + rect.height, bounds.y + bounds.height) - y) };
}
