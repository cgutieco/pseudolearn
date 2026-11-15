import { describe, expect, it } from "vitest";
import { checkSafeArea } from "../../src/layout/safe_area_check.ts";
import { slot } from "../support/catalog.ts";

const header = slot("apple.header.video");
const inside = { x: 1200, y: 600, width: 1000, height: 300 };

describe("checkSafeArea", () => {
  it("accepts essential elements inside the official zone", () => {
    const frames = [{ timeSeconds: 0, elements: [{ name: "lockup", rect: inside, essential: true }] }];
    expect(checkSafeArea({ slot: header, frames, profiles: [] })).toEqual([]);
  });

  it("reports an essential element that leaves the zone at the frame it happens", () => {
    const frames = [
      { timeSeconds: 0, elements: [{ name: "lockup", rect: inside, essential: true }] },
      { timeSeconds: 4.5, elements: [{ name: "lockup", rect: { ...inside, x: 100 }, essential: true }] },
    ];
    expect(checkSafeArea({ slot: header, frames, profiles: [] }))
      .toEqual([{ timeSeconds: 4.5, element: "lockup", reason: "leaves the safe area" }]);
  });

  it("lets decoration bleed outside the zone but not outside the canvas", () => {
    const frames = [{ timeSeconds: 1, elements: [
      { name: "texture", rect: { x: 0, y: 0, width: 3840, height: 1646 }, essential: false },
      { name: "spill", rect: { x: 3800, y: 0, width: 100, height: 10 }, essential: false },
    ] }];
    expect(checkSafeArea({ slot: header, frames, profiles: [] }))
      .toEqual([{ timeSeconds: 1, element: "spill", reason: "leaves the canvas" }]);
  });

  it("adds every device profile that crops or covers the element", () => {
    const profiles = [{ name: "covered phone", viewport: { width: 390, height: 167 }, occlusions: [{ x: 0, y: 0, width: 390, height: 167 }] }];
    const frames = [{ timeSeconds: 0, elements: [{ name: "lockup", rect: inside, essential: true }] }];
    expect(checkSafeArea({ slot: header, frames, profiles }).map((violation) => violation.reason))
      .toEqual(["is cropped or covered in covered phone"]);
  });

  it("returns nothing for a composition with no frames", () => {
    expect(checkSafeArea({ slot: header, frames: [], profiles: [] })).toEqual([]);
  });
});
