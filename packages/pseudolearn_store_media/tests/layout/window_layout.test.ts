import { describe, expect, it } from "vitest";
import { projectRegion, WINDOW_SCALE, WINDOW_TOP, windowRect } from "../../src/layout/window_layout.ts";

const canvas = { width: 3840, height: 2160 };
const plate = { width: 3840, height: 2160 };

describe("windowRect", () => {
  it("centres the scaled window horizontally and hangs it from the top", () => {
    const rect = windowRect(canvas, plate);
    expect(rect.width).toBeCloseTo(3840 * WINDOW_SCALE, 6);
    expect(rect.x).toBeCloseTo((3840 - rect.width) / 2, 6);
    expect(rect.y).toBe(WINDOW_TOP);
    expect(rect.y + rect.height).toBeLessThan(canvas.height);
  });
});

describe("projectRegion", () => {
  const window = { rect: windowRect(canvas, plate), plate };

  it("maps the whole focus rectangle through the window scale", () => {
    const projected = projectRegion({ x: 100, y: 200, width: 1000, height: 500 }, { x: 0, y: 0, width: 1, height: 1 }, window);
    expect(projected).toEqual({ x: window.rect.x + 100 * WINDOW_SCALE, y: WINDOW_TOP + 200 * WINDOW_SCALE, width: 1000 * WINDOW_SCALE, height: 500 * WINDOW_SCALE });
  });

  it("maps a band inside the focus rectangle, down to a single-pixel region", () => {
    const band = projectRegion({ x: 0, y: 0, width: 1000, height: 1000 }, { x: 0.25, y: 0.5, width: 0.5, height: 0.001 }, window);
    expect(band.x).toBeCloseTo(window.rect.x + 250 * WINDOW_SCALE, 6);
    expect(band.height).toBeCloseTo(1 * WINDOW_SCALE, 6);
  });
});
