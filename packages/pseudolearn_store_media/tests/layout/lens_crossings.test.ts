import { describe, expect, it } from "vitest";
import { centralRow, lensCrossings, stillMoment } from "../../src/layout/lens_crossings.ts";
import { lensLayout, rowOffset } from "../../src/layout/lens_layout.ts";
import { slot } from "../support/catalog.ts";
import { SIMPLE_MEASURE } from "../support/lens.ts";

const layout = lensLayout({
  slot: slot("apple.header.video"),
  entries: [{ text: "Leer x;", form: "box" }, { text: "Escribir x;", form: "box" }, { text: "FinProceso", form: "box" }],
  rhythm: { statementsPerRow: 3, statementStride: 1, phaseStride: 0.37 },
  measure: SIMPLE_MEASURE,
});
const middle = layout.lens.x + layout.lens.width / 2;

describe("lensCrossings", () => {
  it("crosses each segment of each lens row once per loop, in order", () => {
    const crossings = lensCrossings(layout, 20);
    expect(crossings).toHaveLength(layout.rows.filter((row) => row.inLens).length * 3);
    expect(crossings.every((crossing, index) => index === 0 || crossings[index - 1]!.atSeconds <= crossing.atSeconds)).toBe(true);
    expect(crossings.every((crossing) => crossing.atSeconds >= 0 && crossing.atSeconds < 20)).toBe(true);
  });

  it("times each crossing when the node centre meets the middle of the lens", () => {
    for (const crossing of lensCrossings(layout, 20)) {
      const row = layout.rows[crossing.row]!;
      const segment = row.segments.find((item) => item.statement === crossing.statement)!;
      const position = (((segment.center - rowOffset(row, crossing.atSeconds, 20) - middle) % row.tile) + row.tile) % row.tile;
      expect(Math.min(position, row.tile - position)).toBeLessThan(1e-6);
    }
  });

  it("ignores rows outside the lens", () => {
    const empty = { ...layout, rows: layout.rows.map((row) => ({ ...row, inLens: false })) };
    expect(lensCrossings(empty, 20)).toEqual([]);
  });
});

describe("stillMoment", () => {
  it("freezes the still on a crossing of the central row", () => {
    const moment = stillMoment(layout, 20, 0);
    expect(lensCrossings(layout, 20).some((crossing) => crossing.row === centralRow(layout) && crossing.atSeconds === moment)).toBe(true);
  });

  it("wraps to the first crossing when asked after the last one", () => {
    const central = lensCrossings(layout, 20).filter((crossing) => crossing.row === centralRow(layout));
    const expected = central.find((crossing) => crossing.atSeconds >= 19.999) ?? central[0]!;
    expect(stillMoment(layout, 20, 19.999)).toBe(expected.atSeconds);
  });
});
