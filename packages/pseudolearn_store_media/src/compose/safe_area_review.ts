import type { Slot } from "../catalog/catalog_types.ts";
import type { PixelRect } from "../layout/pixel_rect.ts";
import { reviewBoardLayout, REVIEW_GUTTER, type ReviewCell, type ReviewRow } from "../layout/review_board_layout.ts";
import { htmlDocument, type Composition } from "./composition.ts";
import { escapeHtml } from "./html_text.ts";

export type ReviewSample = { readonly timeSeconds: number; readonly image: string };

export type SafeAreaReviewRequest = { readonly slot: Slot; readonly samples: readonly ReviewSample[] };

const STYLE = `#stage { background: #101415; font-family: -apple-system, "Helvetica Neue", Arial, sans-serif; color: #E6ECED; }
.title { position: absolute; left: ${REVIEW_GUTTER}px; top: 36px; font-size: 40px; font-weight: 700; }
.label { position: absolute; font-size: 24px; color: #95D1D4; white-space: nowrap; }
.cell { position: absolute; overflow: hidden; background: #000; outline: 2px solid #2B3638; }
.cell img { position: absolute; display: block; }
.safe { position: absolute; border: 3px dashed #F29045; }
.occlusion { position: absolute; background: rgba(230,236,237,.86); border-radius: 999px; }`;

export function buildSafeAreaReview(request: SafeAreaReviewRequest): Composition {
  const { slot, samples } = request;
  const board = reviewBoardLayout(slot, samples.map((sample) => sample.timeSeconds));
  const id = `safe-area-review-${slot.id.replaceAll(".", "-")}`;
  const title = `<div class="title">${escapeHtml(`${slot.id} · ${slot.width}×${slot.height} · safe area and device crops`)}</div>`;
  const rows = board.rows.map((row, index) => rowMarkup(row, samples[index]?.image ?? "")).join("\n");
  return {
    id,
    canvas: board.size,
    durationSeconds: 1,
    html: htmlDocument({ id, canvas: board.size, durationSeconds: 1, style: STYLE, body: `${title}\n${rows}`, timeline: "" }),
    layout: [],
    texts: [],
  };
}

function rowMarkup(row: ReviewRow, image: string): string {
  return row.cells.map((cell) => cellMarkup(cell, { image, timeSeconds: row.timeSeconds })).join("\n");
}

function cellMarkup(cell: ReviewCell, sample: { image: string; timeSeconds: number }): string {
  const { clip } = cell;
  const local = (rect: PixelRect): string => box({ ...rect, x: rect.x - clip.x, y: rect.y - clip.y });
  const label = `<div class="label" style="left:${clip.x}px;top:${clip.y - 40}px">${escapeHtml(`${sample.timeSeconds.toFixed(2)} s · ${cell.label}`)}</div>`;
  const occlusions = cell.occlusions.map((rect) => `<div class="occlusion" style="${local(rect)}"></div>`).join("");
  return `${label}<div class="cell" style="${box(clip)}"><img src="${escapeHtml(sample.image)}" style="${local(cell.image)}">`
    + `<div class="safe" style="${local(cell.safe)}"></div>${occlusions}</div>`;
}

function box(rect: PixelRect): string {
  return `left:${rect.x}px;top:${rect.y}px;width:${rect.width}px;height:${rect.height}px`;
}
