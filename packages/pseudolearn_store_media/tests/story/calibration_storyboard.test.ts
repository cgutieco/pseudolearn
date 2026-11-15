import { describe, expect, it } from "vitest";
import { calibrationStoryboard } from "../../src/story/calibration_storyboard.ts";
import { slot } from "../support/catalog.ts";

describe("calibrationStoryboard", () => {
  it("lasts the shortest accepted duration and ends on a resolution", () => {
    const storyboard = calibrationStoryboard(slot("apple.header.video"));
    expect(storyboard.durationSeconds).toBe(10);
    expect(storyboard.beats.at(-1)?.kind).toBe("resolve");
  });

  it("is empty for a still slot", () => {
    expect(calibrationStoryboard(slot("apple.mac.screenshot")).beats).toEqual([]);
  });
});
