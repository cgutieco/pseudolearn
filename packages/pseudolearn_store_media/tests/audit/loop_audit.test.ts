import { describe, expect, it } from "vitest";
import { auditLoop, auditLoudness, LOOP_THRESHOLD, meanAbsoluteDifference } from "../../src/audit/loop_audit.ts";

const target = { integratedLufs: -16, toleranceLu: 1, truePeakDb: -1 };

describe("meanAbsoluteDifference", () => {
  it("is zero for identical frames and one for opposite frames", () => {
    expect(meanAbsoluteDifference(new Uint8Array([1, 2, 3]), new Uint8Array([1, 2, 3]))).toBe(0);
    expect(meanAbsoluteDifference(new Uint8Array([0, 0]), new Uint8Array([255, 255]))).toBe(1);
  });

  it("treats frames of different size or empty frames as different", () => {
    expect(meanAbsoluteDifference(new Uint8Array(2), new Uint8Array(3))).toBe(1);
    expect(meanAbsoluteDifference(new Uint8Array(0), new Uint8Array(0))).toBe(1);
  });
});

describe("auditLoop", () => {
  it("accepts compression noise under the threshold", () => {
    const first = new Uint8Array(1000).fill(100);
    const last = new Uint8Array(1000).fill(101);
    expect(auditLoop("piece", first, last)).toEqual([]);
  });

  it("rejects a visible jump", () => {
    const first = new Uint8Array(1000).fill(0);
    const last = new Uint8Array(1000).fill(Math.ceil(LOOP_THRESHOLD * 255 * 2));
    expect(auditLoop("piece", first, last).map((entry) => entry.rule)).toEqual(["MEDIA-LOOP"]);
  });
});

describe("auditLoudness", () => {
  it("accepts a measure inside the tolerance", () => {
    expect(auditLoudness("track", { integratedLufs: -16.8, truePeakDb: -1.5 }, target)).toEqual([]);
  });

  it("rejects a quiet track and a hot peak separately", () => {
    expect(auditLoudness("track", { integratedLufs: -17.6, truePeakDb: -0.5 }, target).map((entry) => entry.message)).toEqual([
      "-17.6 LUFS instead of -16 ± 1",
      "true peak -0.5 dBTP exceeds -1",
    ]);
  });

  it("rejects silence", () => {
    expect(auditLoudness("track", { integratedLufs: Number.NEGATIVE_INFINITY, truePeakDb: Number.NEGATIVE_INFINITY }, target))
      .toHaveLength(1);
  });
});
