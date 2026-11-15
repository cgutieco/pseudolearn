import { codeRow, rowCount, rowPhase, rowY, type CodeBarRequest, type CodeSegment } from "./code_bars.ts";
import type { PixelRect, Size } from "./pixel_rect.ts";

export const LENS_SHARE = { width: 0.62, height: 0.82 };
export const ROWS_PER_LENS = 6;
export const NODE_MARGIN_ROWS = 4.2;

export type MuteLensRow = { readonly y: number; readonly segments: readonly CodeSegment[]; readonly inLens: boolean; readonly middle: boolean };

export type MuteLensLayout = { readonly lens: PixelRect; readonly rows: readonly MuteLensRow[]; readonly rowGap: number };

export type MuteLensRequest = {
  readonly canvas: Size;
  readonly safeArea: PixelRect;
  readonly lines: readonly string[];
  readonly anchor: number;
  readonly measure: (text: string, size: number) => number;
};

export function muteLensRhythm(lensHeight: number) {
  const rowGap = lensHeight / ROWS_PER_LENS;
  return { rowGap, barHeight: rowGap * 0.12, tokenGap: rowGap * 0.14, statementGap: rowGap * 0.72, fontSize: rowGap * 0.238 };
}

export function muteLensLayout(request: MuteLensRequest): MuteLensLayout {
  const { canvas, safeArea } = request;
  const width = safeArea.width * LENS_SHARE.width;
  const height = safeArea.height * LENS_SHARE.height;
  const { fontSize, ...rhythm } = muteLensRhythm(height);
  const lens = { x: safeArea.x + (safeArea.width - width) / 2, y: safeArea.y + (safeArea.height - height) / 2, width, height };
  const bars: CodeBarRequest = { canvas, lines: request.lines, measure: (token) => request.measure(token, fontSize), rhythm };
  const middleRow = Math.round((lens.y + lens.height / 2 - rowY(rhythm, 0)) / rhythm.rowGap);
  const rows = Array.from({ length: rowCount(bars) }, (_unused, row) => {
    const y = rowY(rhythm, row);
    const middle = row === middleRow;
    const origin = middle ? anchoredOrigin(bars, { row, centre: lens.x + lens.width / 2, anchor: request.anchor }) : rowPhase(row);
    return { y, segments: codeRow(bars, row, origin), inLens: y > lens.y + rhythm.rowGap * 0.35 && y < lens.y + lens.height - rhythm.rowGap * 0.35, middle };
  });
  return { lens, rows, rowGap: rhythm.rowGap };
}

function anchoredOrigin(request: CodeBarRequest, place: { row: number; centre: number; anchor: number }): number {
  const cycleEstimate = request.lines.reduce((total, line) => total + request.measure(line) * 2 + request.rhythm.statementGap, 0);
  const probe = codeRow({ ...request, canvas: { ...request.canvas, width: cycleEstimate * 3 } }, place.row, 0);
  const cycle = probe[request.lines.length]?.start ?? 0;
  const target = probe.find((segment) => segment.statement === place.anchor && segment.start > cycle) ?? probe[0];
  let origin = place.centre - (target?.center ?? 0);
  while (cycle > 0 && origin > 0) {
    origin -= cycle;
  }
  return origin;
}
