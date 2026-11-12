import { describe, expect, it } from "vitest";
import { CALIBRATION_VOICE, frequencyOf, loopLockedFrequency, scoreFor } from "../../src/audio/score.ts";

describe("frequencyOf", () => {
  it("returns the root at degree zero", () => {
    expect(frequencyOf(CALIBRATION_VOICE, 0, 0)).toBeCloseTo(146.83, 2);
  });

  it("climbs the whole span of the scale per lap and one octave per octave argument", () => {
    const lap = CALIBRATION_VOICE.scale.length;
    expect(frequencyOf(CALIBRATION_VOICE, lap, 0)).toBeCloseTo(4 * 146.83, 2);
    expect(frequencyOf(CALIBRATION_VOICE, 0, 1)).toBeCloseTo(2 * 146.83, 2);
  });

  it("keeps every degree of one lap ascending", () => {
    const lap = CALIBRATION_VOICE.scale.length;
    const frequencies = Array.from({ length: 2 * lap }, (_, degree) => frequencyOf(CALIBRATION_VOICE, degree - lap, 0));
    expect(frequencies.every((value, index) => index === 0 || value > (frequencies[index - 1] ?? 0))).toBe(true);
  });

  it("wraps negative degrees below the root", () => {
    expect(frequencyOf(CALIBRATION_VOICE, -1, 0)).toBeLessThan(146.83);
  });
});

describe("loopLockedFrequency", () => {
  it("rounds to a whole number of cycles over the loop", () => {
    const locked = loopLockedFrequency(146.83, 15);
    expect(Number.isInteger(Math.round(locked * 15 * 1e6) / 1e6)).toBe(true);
    expect(Math.abs(locked - 146.83)).toBeLessThan(1 / 15);
  });

  it("never drops below one cycle", () => {
    expect(loopLockedFrequency(0.001, 10)).toBeCloseTo(0.1, 6);
  });
});

describe("scoreFor", () => {
  it("takes duration and beats from the storyboard", () => {
    const beats = [{ atSeconds: 1, kind: "step" as const, degree: 0, weight: 1 }];
    const score = scoreFor({ id: "story", durationSeconds: 12, beats }, CALIBRATION_VOICE, 48000);
    expect(score.durationSeconds).toBe(12);
    expect(score.beats).toBe(beats);
  });
});
