import { describe, expect, it } from "vitest";
import { clearZone } from "../../src/layout/clear_zone.ts";
import { copiesToCover, lensLayout, rowOffset, wholeRowGap, type LensEntry } from "../../src/layout/lens_layout.ts";
import { contains } from "../../src/layout/pixel_rect.ts";
import { slot } from "../support/catalog.ts";
import { SIMPLE_MEASURE } from "../support/lens.ts";

const entries: readonly LensEntry[] = [
  { text: "Proceso Demo", form: "box" },
  { text: "Mientras x > 0 Hacer", form: "tall" },
  { text: "x <- x - 1;", form: "box" },
  { text: "FinMientras", form: "dot" },
];
const rhythm = { statementsPerRow: 3, statementStride: 1, phaseStride: 0.37 };

function layoutFor(id: string) {
  return lensLayout({ slot: slot(id), entries, rhythm, measure: SIMPLE_MEASURE });
}

describe("lensLayout", () => {
  it("keeps the lens inside the clear zone of every creative slot", () => {
    for (const id of ["apple.header.video", "apple.search.video", "apple.universal.image"]) {
      expect(contains(clearZone(slot(id)), layoutFor(id).lens), id).toBe(true);
    }
  });

  it("stacks rows from the top to the bottom of the canvas with some inside the lens", () => {
    const layout = layoutFor("apple.header.video");
    expect(layout.rows[0]!.y).toBeLessThan(0);
    expect(layout.rows.at(-1)!.y).toBeGreaterThan(1646);
    expect(layout.rows.filter((row) => row.inLens).length).toBeGreaterThanOrEqual(2);
  });

  it("makes each tile the sum of its segments and rotates the program per row", () => {
    const [first, second] = layoutFor("apple.header.video").rows;
    expect(first!.tile).toBeCloseTo(first!.segments.reduce((total, segment) => total + segment.width, 0), 6);
    expect(second!.segments[0]!.statement).toBe((first!.segments[0]!.statement + 1) % entries.length);
  });

  it("sizes the join as a dot and the decision taller than a box", () => {
    const segments = layoutFor("apple.header.video").rows.flatMap((row) => row.segments);
    const height = (form: string) => segments.find((segment) => segment.form === form)!.nodeHeight;
    expect(segments.find((segment) => segment.form === "dot")!.nodeWidth).toBe(height("dot"));
    expect(height("tall")).toBeGreaterThan(height("box"));
  });

  it("scales the type with the rows that fit in the lens of each slot", () => {
    expect(layoutFor("apple.header.video").unit).toBeCloseTo(1, 1);
    expect(layoutFor("apple.universal.image").monoSize).toBeLessThan(layoutFor("apple.header.video").monoSize);
  });
});

describe("row motion", () => {
  const row = layoutFor("apple.header.video").rows[3]!;

  it("moves exactly one tile per loop, so the loop closes on itself", () => {
    expect(rowOffset(row, 0, 20)).toBeCloseTo(rowOffset(row, 20, 20), 6);
    expect(rowOffset(row, 5, 20)).toBeCloseTo((row.phase + row.tile / 4) % row.tile, 6);
  });

  it("repeats the tile often enough to cover the canvas at any offset", () => {
    expect((copiesToCover(row, 3840) - 1) * row.tile).toBeGreaterThanOrEqual(3840);
  });
});

describe("wholeRowGap", () => {
  it("fits an odd number of whole rows plus the margin in each lens", () => {
    for (const lens of [{ width: 1566, height: 566 }, { width: 2060, height: 970 }, { width: 1332, height: 904 }]) {
      const rows = lens.height / wholeRowGap(lens) - 0.8 + 1;
      expect(Math.abs(rows - Math.round(rows))).toBeLessThan(1e-9);
      expect(Math.round(rows) % 2).toBe(1);
    }
  });

  it("keeps three rows for the header and grows the count where the lens is tall for its width", () => {
    expect(566 / wholeRowGap({ width: 1566, height: 566 })).toBeCloseTo(2.8, 6);
    expect(970 / wholeRowGap({ width: 2060, height: 970 })).toBeCloseTo(4.8, 6);
    expect(904 / wholeRowGap({ width: 1332, height: 904 })).toBeCloseTo(6.8, 6);
  });
});
