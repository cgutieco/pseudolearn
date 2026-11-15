import { describe, expect, it } from "vitest";
import type { DevicePlacement } from "../../src/layout/device_geometry.ts";
import { placePill, plateToCanvas } from "../../src/layout/pin_layout.ts";

const placement: DevicePlacement = {
  outer: { x: 0, y: 0, width: 1100, height: 2200 },
  screen: { x: 100, y: 200, width: 1000, height: 2000 },
  screenRadius: 40,
  rotation: 0,
};
const plate = { width: 500, height: 1000 };
const safe = { x: 0, y: 0, width: 2000, height: 3000 };

describe("plateToCanvas", () => {
  it("maps a focus rectangle and its pin from plate pixels to the canvas", () => {
    const mapped = plateToCanvas({ placement, plate, focus: { x: 100, y: 100, width: 200, height: 100 }, pin: { x: 0.5, y: 1 } }, "none");
    expect(mapped.highlight).toEqual({ x: 300, y: 400, width: 400, height: 200 });
    expect(mapped.point).toEqual({ x: 500, y: 600 });
  });

  it("pulls points toward the hinge of a vertical fold", () => {
    const focus = { x: 450, y: 0, width: 50, height: 10 };
    const flat = plateToCanvas({ placement, plate, focus, pin: { x: 1, y: 0 } }, "none");
    const folded = plateToCanvas({ placement, plate, focus, pin: { x: 1, y: 0 } }, "vertical");
    expect(folded.point.x).toBeLessThan(flat.point.x);
    expect(folded.point.y).toBe(flat.point.y);
  });

  it("clips a focus that extends past the recorded plate", () => {
    const mapped = plateToCanvas({ placement, plate, focus: { x: 0, y: 900, width: 500, height: 400 }, pin: { x: 0, y: 0 } }, "none");
    expect(mapped.highlight.y + mapped.highlight.height).toBe(placement.screen.y + placement.screen.height);
  });
});

describe("placePill", () => {
  it("puts the note above the pin when the headline is clear of it", () => {
    const pill = placePill({ pin: { x: 500, y: 1000 }, size: { width: 300, height: 80 }, safe, avoid: { x: 0, y: 0, width: 2000, height: 500 } });
    expect(pill.y + pill.height).toBeLessThan(1000);
  });

  it("puts the note below the pin when going up would hit the headline above it", () => {
    const pill = placePill({ pin: { x: 500, y: 560 }, size: { width: 300, height: 80 }, safe, avoid: { x: 0, y: 0, width: 2000, height: 500 } });
    expect(pill.y).toBeGreaterThan(560);
  });

  it("goes above a headline that sits beside it and stays inside the margin", () => {
    const beside = placePill({ pin: { x: 1500, y: 560 }, size: { width: 300, height: 80 }, safe, avoid: { x: 0, y: 0, width: 1000, height: 900 } });
    const edge = placePill({ pin: { x: 1990, y: 2000 }, size: { width: 300, height: 80 }, safe, avoid: { x: 0, y: 0, width: 10, height: 10 } });
    expect(beside.y + beside.height).toBeLessThan(560);
    expect(edge.x + edge.width).toBeLessThanOrEqual(2000);
  });
});
