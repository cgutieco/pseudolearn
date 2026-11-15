import { describe, expect, it } from "vitest";
import { CALIBRATION_VOICE, type Score } from "../../src/audio/score.ts";
import { synthesize } from "../../src/audio/synthesizer.ts";

const SAMPLE_RATE = 8000;

function score(overrides: Partial<Score> = {}): Score {
  return { sampleRate: SAMPLE_RATE, durationSeconds: 2, voice: CALIBRATION_VOICE, beats: [], ...overrides };
}

function energy(samples: Float32Array, from: number, to: number): number {
  let total = 0;
  for (let index = from; index < to; index += 1) {
    total += (samples[index] ?? 0) ** 2;
  }
  return total;
}

describe("synthesize", () => {
  it("is deterministic", () => {
    const beats = [{ atSeconds: 0.5, kind: "accent" as const, degree: 2, weight: 1 }];
    expect(synthesize(score({ beats })).left).toEqual(synthesize(score({ beats })).left);
  });

  it("produces exactly the samples of the storyboard", () => {
    const signal = synthesize(score({ durationSeconds: 1.5 }));
    expect(signal.left.length).toBe(12000);
    expect(signal.right.length).toBe(12000);
  });

  it("closes the pad loop without a jump", () => {
    const signal = synthesize(score());
    const first = signal.left[0] ?? 0;
    const last = signal.left[signal.left.length - 1] ?? 0;
    expect(Math.abs(first - last)).toBeLessThan(0.02);
  });

  it("places a cue at its beat", () => {
    const quiet = synthesize(score({ durationSeconds: 4, voice: { ...CALIBRATION_VOICE, padGain: 0 }, beats: [{ atSeconds: 1, kind: "step", degree: 0, weight: 1 }] }));
    expect(energy(quiet.left, 0, SAMPLE_RATE * 0.9)).toBe(0);
    expect(energy(quiet.left, SAMPLE_RATE, SAMPLE_RATE * 1.2)).toBeGreaterThan(0);
  });

  it("wraps the tail of a late cue into the start so the loop stays continuous", () => {
    const quiet = synthesize(score({ voice: { ...CALIBRATION_VOICE, padGain: 0 }, beats: [{ atSeconds: 1.95, kind: "resolve", degree: 0, weight: 1 }] }));
    expect(energy(quiet.left, 0, SAMPLE_RATE * 0.2)).toBeGreaterThan(0);
  });

  it("is silent for a voice with no gain and no beats", () => {
    const silent = synthesize(score({ voice: { ...CALIBRATION_VOICE, padGain: 0, cueGain: 0 } }));
    expect(energy(silent.left, 0, silent.left.length)).toBe(0);
  });

  it("returns an empty signal for a zero duration", () => {
    expect(synthesize(score({ durationSeconds: 0 })).left.length).toBe(0);
  });
});
