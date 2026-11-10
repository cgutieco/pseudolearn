import { describe, expect, it } from "vitest";
import { calibrationStoryboard } from "../../src/story/calibration_storyboard.ts";
import { storyboardProblems, type Storyboard } from "../../src/story/storyboard.ts";
import { slot } from "../support/catalog.ts";

const preview = slot("apple.iphone.app-preview");

describe("storyboardProblems", () => {
  it("accepts the calibration storyboard of every video slot", () => {
    for (const id of ["apple.iphone.app-preview", "apple.header.video", "apple.search.video", "microsoft.trailer"]) {
      const target = slot(id);
      expect(storyboardProblems(calibrationStoryboard(target), target)).toEqual([]);
    }
  });

  it("rejects a duration outside the slot range and a still slot", () => {
    const short: Storyboard = { id: "short", durationSeconds: 5, beats: [] };
    expect(storyboardProblems(short, preview)).toEqual(["duration 5s is outside 15–30s"]);
    expect(storyboardProblems(short, slot("apple.mac.screenshot"))).toEqual(["apple.mac.screenshot is not a video slot"]);
  });

  it("rejects beats outside the storyboard, out of order or without weight", () => {
    const storyboard: Storyboard = {
      id: "broken",
      durationSeconds: 15,
      beats: [
        { atSeconds: 3, kind: "step", degree: 0, weight: 1 },
        { atSeconds: 2, kind: "step", degree: 0, weight: 0 },
        { atSeconds: 15, kind: "resolve", degree: 0, weight: 1 },
      ],
    };
    expect(storyboardProblems(storyboard, preview)).toEqual([
      "beat 1 weight must be in (0, 1]",
      "beat 1 is out of order",
      "beat 2 at 15s falls outside the storyboard",
    ]);
  });
});
