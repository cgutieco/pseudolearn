import type { LensLayout } from "./lens_layout.ts";

export type LensCrossing = { readonly atSeconds: number; readonly row: number; readonly statement: number };

export function lensCrossings(layout: LensLayout, durationSeconds: number): readonly LensCrossing[] {
  const middle = layout.lens.x + layout.lens.width / 2;
  return layout.rows.flatMap((row, rowIndex) => {
    if (!row.inLens) {
      return [];
    }
    return row.segments.map((segment) => {
      const distance = (((segment.center - row.phase - middle) % row.tile) + row.tile) % row.tile;
      return { atSeconds: (distance / row.tile) * durationSeconds, row: rowIndex, statement: segment.statement };
    });
  }).sort((first, second) => first.atSeconds - second.atSeconds);
}

export function centralRow(layout: LensLayout): number {
  const middle = layout.lens.y + layout.lens.height / 2;
  return layout.rows.reduce((best, row, index) => {
    const current = layout.rows[best];
    return current && Math.abs(current.y - middle) <= Math.abs(row.y - middle) ? best : index;
  }, 0);
}

export function stillMoment(layout: LensLayout, durationSeconds: number, afterSeconds: number): number {
  const row = centralRow(layout);
  const crossings = lensCrossings(layout, durationSeconds).filter((crossing) => crossing.row === row);
  const next = crossings.find((crossing) => crossing.atSeconds >= afterSeconds) ?? crossings[0];
  return next?.atSeconds ?? afterSeconds;
}
