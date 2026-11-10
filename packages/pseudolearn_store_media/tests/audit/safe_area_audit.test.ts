import { describe, expect, it } from "vitest";
import { auditSafeArea } from "../../src/audit/safe_area_audit.ts";
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
