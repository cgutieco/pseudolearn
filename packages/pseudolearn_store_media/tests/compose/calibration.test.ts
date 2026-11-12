import { describe, expect, it } from "vitest";
import { buildCalibration } from "../../src/compose/calibration.ts";
import { checkSafeArea } from "../../src/layout/safe_area_check.ts";
import { realCatalog, slot } from "../support/catalog.ts";

const header = slot("apple.header.video");

describe("buildCalibration", () => {
  it("declares the HyperFrames composition the producer expects", () => {
    const composition = buildCalibration({ slot: header, durationSeconds: 10, beats: [], guides: false });
    expect(composition.html).toContain('data-composition-id="calibration-apple-header-video"');
    expect(composition.html).toContain('data-width="3840" data-height="1646"');
    expect(composition.html).toContain('window.__timelines["calibration-apple-header-video"] = timeline;');
    expect(composition.html).toContain("timeline.set({}, {}, 10);");
    expect(composition.html).not.toContain('id="guide"');
  });

  it("draws the safe-area guide only on request", () => {
    expect(buildCalibration({ slot: header, durationSeconds: 10, beats: [], guides: true }).html).toContain('id="guide"');
  });

  it("keeps the lockup inside the safe area of every slot, at its largest pulse", () => {
    for (const target of realCatalog().slots) {
      const composition = buildCalibration({ slot: target, durationSeconds: 15, beats: [], guides: false });
      expect(checkSafeArea({ slot: target, frames: composition.layout, profiles: [] })).toEqual([]);
    }
  });

  it("skips pulses that would run past the end of the loop", () => {
    const beats = [
      { atSeconds: 1, kind: "accent" as const, degree: 0, weight: 1 },
      { atSeconds: 9.9, kind: "resolve" as const, degree: 0, weight: 1 },
    ];
    const html = buildCalibration({ slot: header, durationSeconds: 10, beats, guides: false }).html;
    expect(html.match(/timeline\.to\("#lockup"/gu)).toHaveLength(1);
  });

  it("carries no editorial text", () => {
    expect(buildCalibration({ slot: header, durationSeconds: 10, beats: [], guides: false }).texts).toEqual([]);
  });
});
