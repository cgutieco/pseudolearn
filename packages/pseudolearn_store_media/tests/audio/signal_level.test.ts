import { describe, expect, it } from "vitest";
import { gainToTarget, samplePeakDb, withGain } from "../../src/audio/signal_level.ts";

const signal = { sampleRate: 48000, left: new Float32Array([0, 0.5, -0.25]), right: new Float32Array([0.1, -0.5, 0]) };

describe("samplePeakDb", () => {
  it("measures the largest magnitude of both channels", () => {
    expect(samplePeakDb(signal)).toBeCloseTo(-6.02, 2);
  });

  it("reports minus infinity for silence", () => {
    expect(samplePeakDb({ sampleRate: 48000, left: new Float32Array(4), right: new Float32Array(4) })).toBe(Number.NEGATIVE_INFINITY);
  });
});

describe("withGain", () => {
  it("scales every sample without touching the original", () => {
    const louder = withGain(signal, 6.0206);
    expect(louder.left[1]).toBeCloseTo(1, 4);
    expect(signal.left[1]).toBe(0.5);
  });
});

describe("gainToTarget", () => {
  it("reaches the target when the peak allows it", () => {
    expect(gainToTarget({ measuredLufs: -21, targetLufs: -16, measuredTruePeakDb: -9, ceilingDb: -1.2 }))
      .toEqual({ gainDb: 5, limitedByPeak: false });
  });

  it("stops at the peak ceiling and says so", () => {
    const plan = gainToTarget({ measuredLufs: -24, targetLufs: -16, measuredTruePeakDb: -6, ceilingDb: -1.2 });
    expect(plan.limitedByPeak).toBe(true);
    expect(plan.gainDb).toBeCloseTo(4.8, 6);
  });

  it("attenuates a signal that is too loud", () => {
    expect(gainToTarget({ measuredLufs: -10, targetLufs: -16, measuredTruePeakDb: 0, ceilingDb: -1 }).gainDb).toBe(-6);
  });
});
