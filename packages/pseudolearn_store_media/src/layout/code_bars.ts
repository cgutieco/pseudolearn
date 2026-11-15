import type { Size } from "./pixel_rect.ts";

export const CODE_BAR_ROLES = ["keyword", "number", "text", "symbol", "name"] as const;
export type CodeBarRole = (typeof CODE_BAR_ROLES)[number];

export type CodeBar = { readonly x: number; readonly y: number; readonly width: number; readonly height: number; readonly role: CodeBarRole };

export type CodeSegment = { readonly start: number; readonly end: number; readonly center: number; readonly statement: number; readonly bars: readonly CodeBar[] };

export type CodeRhythm = { readonly rowGap: number; readonly barHeight: number; readonly tokenGap: number; readonly statementGap: number };

export type CodeBarRequest = {
  readonly canvas: Size;
  readonly lines: readonly string[];
  readonly measure: (text: string) => number;
  readonly rhythm: CodeRhythm;
};

const PHASE_STRIDE = 0.37;
const PHASE_SPAN = 1100;
export const STATEMENT_STRIDE = 3;

export function codeBars(request: CodeBarRequest): readonly CodeBar[] {
  const { canvas } = request;
  return Array.from({ length: rowCount(request) }, (_unused, row) => codeRow(request, row, rowPhase(row)))
    .flat().flatMap((segment) => segment.bars)
    .filter((bar) => bar.x < canvas.width && bar.x + bar.width > 0);
}

export function rowCount(request: CodeBarRequest): number {
  return Math.ceil(request.canvas.height / request.rhythm.rowGap) + 1;
}

export function rowY(rhythm: CodeRhythm, row: number): number {
  return rhythm.rowGap / 2 + row * rhythm.rowGap;
}

export function rowPhase(row: number): number {
  return -((row * PHASE_STRIDE) % 1) * PHASE_SPAN;
}

export function roleOf(token: string, leading: boolean): CodeBarRole {
  if (token.startsWith("\"")) {
    return "text";
  }
  if (/^\d/u.test(token)) {
    return "number";
  }
  if (leading) {
    return "keyword";
  }
  return /^[<>=+\-*/]+$/u.test(token) ? "symbol" : "name";
}

export function codeRow(request: CodeBarRequest, row: number, origin: number): readonly CodeSegment[] {
  const { canvas, lines, rhythm } = request;
  const segments: CodeSegment[] = [];
  const y = rowY(rhythm, row) - rhythm.barHeight / 2;
  let x = origin;
  for (let statement = row * STATEMENT_STRIDE; x < canvas.width && lines.length > 0; statement += 1) {
    const index = statement % lines.length;
    const start = x;
    const bars: CodeBar[] = [];
    for (const [position, token] of (lines[index]?.match(/"[^"]*"|\S+/gu) ?? []).entries()) {
      const width = request.measure(token);
      bars.push({ x, y, width, height: rhythm.barHeight, role: roleOf(token, position === 0) });
      x += width + rhythm.tokenGap;
    }
    const end = Math.max(start, x - rhythm.tokenGap);
    segments.push({ start, end, center: (start + end) / 2, statement: index, bars });
    x += rhythm.statementGap;
  }
  return segments;
}
