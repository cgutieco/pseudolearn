import type { Slot } from "../catalog/catalog_types.ts";
import { clearZone } from "./clear_zone.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";

export const NODE_FORMS = ["box", "tall", "dot"] as const;
export type NodeForm = (typeof NODE_FORMS)[number];

export type LensEntry = { readonly text: string; readonly form: NodeForm };
export type LensRhythm = { readonly statementsPerRow: number; readonly statementStride: number; readonly phaseStride: number };
export type TextMeasure = { readonly mono: (text: string, size: number) => number; readonly sans: (text: string, size: number) => number };

export type LensSegment = {
  readonly text: string;
  readonly form: NodeForm;
  readonly statement: number;
  readonly start: number;
  readonly width: number;
  readonly center: number;
  readonly nodeWidth: number;
  readonly nodeHeight: number;
};

export type LensRow = { readonly y: number; readonly tile: number; readonly phase: number; readonly inLens: boolean; readonly segments: readonly LensSegment[] };

export type LensLayout = {
  readonly canvas: Size;
  readonly lens: PixelRect;
  readonly unit: number;
  readonly monoSize: number;
  readonly sansSize: number;
  readonly rows: readonly LensRow[];
};

export type LensLayoutRequest = {
  readonly slot: Slot;
  readonly entries: readonly LensEntry[];
  readonly rhythm: LensRhythm;
  readonly measure: TextMeasure;
};

export const LENS_INSET = { horizontal: 0.025, vertical: 0.03 };
export const LENS_MARGIN_IN_ROWS = 0.8;
export const ROW_GAPS_PER_LENS_WIDTH = 7.8;
export const ROW_GAP_TOLERANCE = 1.05;
export const REFERENCE_ROW_GAP = 200;
const SIZES = { mono: 0.42, sans: 0.27, node: 0.62, tall: 0.75, dot: 0.26, gap: 1.2, padding: 0.55 };

export function lensLayout(request: LensLayoutRequest): LensLayout {
  const { slot } = request;
  const canvas = { width: slot.width, height: slot.height };
  const clear = clearZone(slot);
  const lens = {
    x: clear.x + clear.width * LENS_INSET.horizontal,
    y: clear.y + clear.height * LENS_INSET.vertical,
    width: clear.width * (1 - 2 * LENS_INSET.horizontal),
    height: clear.height * (1 - 2 * LENS_INSET.vertical),
  };
  const rowGap = wholeRowGap(lens);
  const center = lens.y + lens.height / 2;
  const reach = Math.ceil((Math.max(center, canvas.height - center) + rowGap) / rowGap);
  const rows = Array.from({ length: 2 * reach + 1 }, (_unused, index) => {
    const y = center + (index - reach) * rowGap;
    return rowAt({ request, index, y, rowGap, inLens: y > lens.y && y < lens.y + lens.height });
  });
  return { canvas, lens, unit: rowGap / REFERENCE_ROW_GAP, monoSize: rowGap * SIZES.mono, sansSize: rowGap * SIZES.sans, rows };
}

export function wholeRowGap(lens: Size): number {
  const widest = (lens.width / ROW_GAPS_PER_LENS_WIDTH) * ROW_GAP_TOLERANCE;
  let rows = 3;
  while (lens.height / (rows - 1 + LENS_MARGIN_IN_ROWS) > widest) {
    rows += 2;
  }
  return lens.height / (rows - 1 + LENS_MARGIN_IN_ROWS);
}

type RowRequest = { readonly request: LensLayoutRequest; readonly index: number; readonly y: number; readonly rowGap: number; readonly inLens: boolean };

function rowAt(row: RowRequest): LensRow {
  const { entries, rhythm, measure } = row.request;
  const gap = row.rowGap * SIZES.gap;
  let start = 0;
  const segments = Array.from({ length: rhythm.statementsPerRow }, (_unused, offset) => {
    const statement = (row.index * rhythm.statementStride + offset) % entries.length;
    const entry = entries[statement] ?? { text: "", form: "box" as const };
    const textWidth = measure.mono(entry.text, row.rowGap * SIZES.mono);
    const segment = { ...entry, statement, start, width: textWidth + gap, center: start + textWidth / 2, ...nodeSize(entry, { textWidth, rowGap: row.rowGap, measure }) };
    start += segment.width;
    return segment;
  });
  const fraction = (row.index * rhythm.phaseStride) % 1;
  return { y: row.y, tile: start, phase: fraction * start, inLens: row.inLens, segments };
}

function nodeSize(entry: LensEntry, context: { textWidth: number; rowGap: number; measure: TextMeasure }): { nodeWidth: number; nodeHeight: number } {
  const { rowGap, measure, textWidth } = context;
  if (entry.form === "dot") {
    return { nodeWidth: rowGap * SIZES.dot, nodeHeight: rowGap * SIZES.dot };
  }
  const labelled = measure.sans(entry.text, rowGap * SIZES.sans) + rowGap * SIZES.padding;
  return { nodeWidth: Math.min(textWidth, labelled), nodeHeight: rowGap * (entry.form === "tall" ? SIZES.tall : SIZES.node) };
}

export function rowOffset(row: LensRow, timeSeconds: number, durationSeconds: number): number {
  return (((row.phase + (row.tile * timeSeconds) / durationSeconds) % row.tile) + row.tile) % row.tile;
}

export function copiesToCover(row: LensRow, canvasWidth: number): number {
  return Math.ceil((canvasWidth + row.tile) / row.tile) + 1;
}
