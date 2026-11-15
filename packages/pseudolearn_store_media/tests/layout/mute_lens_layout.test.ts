import { describe, expect, it } from "vitest";
import { LENS_SHARE, muteLensLayout, ROWS_PER_LENS } from "../../src/layout/mute_lens_layout.ts";

const lines = ["Proceso Demo", "Definir t <- 30;", "Mientras t > 24 Hacer", "t <- t - 3;", "FinMientras"];
const measure = (text: string, size: number) => text.length * size * 0.6;
const hero = { canvas: { width: 3840, height: 2160 }, safeArea: { x: 384, y: 216, width: 3072, height: 1224 } };

describe("muteLensLayout", () => {
  it("centres the lens in the safe area and spaces six rows inside it", () => {
    const layout = muteLensLayout({ ...hero, lines, anchor: 2, measure });
    expect(layout.lens.width).toBeCloseTo(3072 * LENS_SHARE.width, 6);
    expect(layout.lens.x + layout.lens.width / 2).toBeCloseTo(384 + 1536, 6);
    expect(layout.rowGap).toBeCloseTo(layout.lens.height / ROWS_PER_LENS, 6);
    expect(layout.rows.filter((row) => row.inLens).length).toBeGreaterThanOrEqual(5);
  });

  it("puts the anchored statement at the centre of the lens on the middle row", () => {
    const layout = muteLensLayout({ ...hero, lines, anchor: 2, measure });
    const middle = layout.rows.filter((row) => row.middle);
    expect(middle).toHaveLength(1);
    const centre = layout.lens.x + layout.lens.width / 2;
    const anchored = middle[0]!.segments.filter((segment) => segment.statement === 2).map((segment) => Math.abs(segment.center - centre));
    expect(Math.min(...anchored)).toBeLessThan(1e-6);
    expect(middle[0]!.segments[0]!.start).toBeLessThanOrEqual(0);
  });

  it("keeps a portrait poster lens inside its safe area", () => {
    const layout = muteLensLayout({ canvas: { width: 1440, height: 2160 }, safeArea: { x: 115, y: 130, width: 1210, height: 1310 }, lines, anchor: 2, measure });
    expect(layout.lens.y + layout.lens.height).toBeLessThanOrEqual(130 + 1310);
    expect(layout.lens.x).toBeGreaterThanOrEqual(115);
  });

  it("draws an empty river for an empty program without looping forever", () => {
    const layout = muteLensLayout({ ...hero, lines: [], anchor: 0, measure });
    expect(layout.rows.every((row) => row.segments.length === 0)).toBe(true);
  });
});
