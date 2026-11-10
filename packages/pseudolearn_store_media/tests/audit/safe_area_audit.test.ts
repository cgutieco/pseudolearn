import { describe, expect, it } from "vitest";
import { auditFrameCoverage, auditSafeArea } from "../../src/audit/safe_area_audit.ts";
import { slot } from "../support/catalog.ts";

const universal = slot("apple.universal.image");

describe("auditSafeArea", () => {
  it("returns no findings for an element inside the universal zone", () => {
    const frames = [{ timeSeconds: 0, elements: [{ name: "lockup", rect: { x: 2000, y: 800, width: 1200, height: 300 }, essential: true }] }];
    expect(auditSafeArea("universal", { slot: universal, frames, profiles: [] })).toEqual([]);
  });

  it("turns each violation into a MEDIA-SAFE-AREA finding with its time", () => {
    const frames = [{ timeSeconds: 2, elements: [{ name: "lockup", rect: { x: 2000, y: 2000, width: 1200, height: 300 }, essential: true }] }];
    expect(auditSafeArea("universal", { slot: universal, frames, profiles: [] })).toEqual([
      { rule: "MEDIA-SAFE-AREA", target: "universal", message: "lockup leaves the safe area at 2.00s" },
    ]);
  });
});

describe("auditFrameCoverage", () => {
  const lockup = [{ name: "lockup", rect: { x: 0, y: 0, width: 1, height: 1 }, essential: true }];

  it("accepts a layout that checks every frame", () => {
    const layout = [0, 1, 2].map((index) => ({ timeSeconds: index / 30, elements: lockup }));
    expect(auditFrameCoverage("header", { durationSeconds: 0.1, fps: 30 }, layout)).toEqual([]);
  });

  it("rejects a layout that checks a single frame of a moving piece", () => {
    const findings = auditFrameCoverage("header", { durationSeconds: 10, fps: 30 }, [{ timeSeconds: 0, elements: lockup }]);
    expect(findings).toEqual([{ rule: "MEDIA-SAFE-AREA", target: "header",
      message: "layout misses 299 frames (1, 2, 3, 4, 5, …); every frame must be checked" }]);
  });
});
