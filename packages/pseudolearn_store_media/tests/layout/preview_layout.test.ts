import { describe, expect, it } from "vitest";
import { CAPTION_BANDS, pixelInsets, placeCaption } from "../../src/layout/preview_layout.ts";

const narrow = (text: string, size: number): number => text.length * size * 0.5;
const phone = { width: 886, height: 1920 };
const insets = pixelInsets({ top: 62, right: 0, bottom: 34, left: 0 }, 2);

describe("placeCaption", () => {
  it("puts a headline below the top inset at the largest size that fits", () => {
    const placed = placeCaption({ canvas: phone, insets, role: "headline", lines: ["Tu programa", "cobra vida."], anchor: null }, narrow);
    expect(placed.fit.fits).toBe(true);
    expect(placed.fit.fontSize).toBe(Math.floor(886 * CAPTION_BANDS.headline.maximumShare));
    expect(placed.panel.y).toBeGreaterThanOrEqual(124);
    expect(placed.panel.x + placed.panel.width).toBeLessThanOrEqual(886);
    expect(placed.coverFraction).toBeGreaterThan(0);
    expect(placed.coverFraction).toBeLessThan(0.15);
  });

  it("puts notes and disclosures above the bottom inset", () => {
    const placed = placeCaption({ canvas: phone, insets, role: "disclosure", lines: ["Nodo requiere suscripción."], anchor: null }, narrow);
    expect(placed.panel.y + placed.panel.height).toBeLessThanOrEqual(1920 - 68);
    expect(placed.panel.y).toBeGreaterThan(1920 / 2);
  });

  it("shrinks long text down to the minimum and reports what still overflows", () => {
    const long = "x".repeat(200);
    const placed = placeCaption({ canvas: phone, insets, role: "note", lines: [long], anchor: null }, narrow);
    expect(placed.fit.fits).toBe(false);
    expect(placed.fit.fits ? [] : placed.fit.overflowingLines).toEqual([long]);
  });

  it("lets the story move a caption to the other edge, away from the interface it would hide", () => {
    const placed = placeCaption({ canvas: phone, insets, role: "headline", lines: ["Nodo"], anchor: "bottom" }, narrow);
    expect(placed.panel.y + placed.panel.height).toBeLessThanOrEqual(1920 - 68);
    expect(placed.panel.y).toBeGreaterThan(1920 / 2);
  });

  it("scales the sizes with the short side on a landscape Mac canvas", () => {
    const placed = placeCaption({ canvas: { width: 1920, height: 1080 }, insets: pixelInsets({ top: 0, right: 0, bottom: 0, left: 0 }, 2),
      role: "headline", lines: ["Corre"], anchor: null }, narrow);
    expect(placed.fit.fontSize).toBe(Math.floor(1080 * CAPTION_BANDS.headline.maximumShare));
  });
});
