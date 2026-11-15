import { describe, expect, it } from "vitest";
import { isClearIn, project, projectionOf, type ViewportProfile } from "../../src/layout/crop_projection.ts";

const canvas = { width: 3840, height: 1646 };
const portraitPhone: ViewportProfile = { name: "portrait phone", viewport: { width: 390, height: 167 }, occlusions: [] };

describe("projectionOf", () => {
  it("fills the viewport and centres the crop", () => {
    const projection = projectionOf({ name: "tall", viewport: { width: 300, height: 300 }, occlusions: [] }, canvas);
    expect(projection.scale).toBeCloseTo(300 / 1646, 6);
    expect(projection.offsetY).toBeCloseTo(0, 6);
    expect(projection.offsetX).toBeLessThan(0);
  });

  it("is the identity when the viewport is the canvas", () => {
    const projection = projectionOf({ name: "same", viewport: canvas, occlusions: [] }, canvas);
    expect(project({ x: 10, y: 20, width: 30, height: 40 }, projection)).toEqual({ x: 10, y: 20, width: 30, height: 40 });
  });
});

describe("isClearIn", () => {
  it("accepts a centred rectangle", () => {
    expect(isClearIn(portraitPhone, canvas, { x: 1700, y: 700, width: 400, height: 200 })).toBe(true);
  });

  it("rejects a rectangle the crop cuts off", () => {
    const narrow = { name: "narrow", viewport: { width: 200, height: 200 }, occlusions: [] };
    expect(isClearIn(narrow, canvas, { x: 0, y: 700, width: 300, height: 200 })).toBe(false);
  });

  it("rejects a rectangle under an occlusion", () => {
    const covered = { ...portraitPhone, occlusions: [{ x: 180, y: 70, width: 30, height: 30 }] };
    expect(isClearIn(covered, canvas, { x: 1700, y: 700, width: 400, height: 200 })).toBe(false);
  });

  it("treats touching edges as clear", () => {
    const viewport = { name: "exact", viewport: canvas, occlusions: [{ x: 0, y: 0, width: 100, height: 100 }] };
    expect(isClearIn(viewport, canvas, { x: 100, y: 0, width: 50, height: 50 })).toBe(true);
  });
});
