import { describe, expect, it } from "vitest";
import { LOOP_THRESHOLD } from "../../src/audit/loop_audit.ts";
import { auditLoopSeam, seamAllowance, type SeamFrames } from "../../src/audit/loop_seam_audit.ts";

function frame(value: number): Uint8Array {
  return new Uint8Array(300).fill(value);
}

function moving(step: number, seamTo: number): SeamFrames {
  return { antepenultimate: frame(100 - 3 * step), penultimate: frame(100 - 2 * step), last: frame(100 - step),
    first: frame(seamTo), second: frame(seamTo + step), third: frame(seamTo + 2 * step) };
}

describe("auditLoopSeam", () => {
  it("accepts a still loop whose seam is compression noise", () => {
    expect(auditLoopSeam("piece", moving(0, 100))).toEqual([]);
  });

  it("accepts a moving loop whose seam is one more step of the same motion", () => {
    expect(auditLoopSeam("piece", moving(4, 100))).toEqual([]);
  });

  it("rejects a still loop that jumps at the seam", () => {
    expect(auditLoopSeam("piece", moving(0, 140)).map((entry) => entry.rule)).toEqual(["MEDIA-LOOP"]);
  });

  it("rejects a moving loop whose seam jumps far more than its motion", () => {
    const findings = auditLoopSeam("piece", moving(2, 160));
    expect(findings.map((entry) => entry.rule)).toEqual(["MEDIA-LOOP"]);
    expect(findings[0]?.message).toContain("more than the");
  });

  it("never allows less than the still threshold", () => {
    expect(seamAllowance(moving(0, 100))).toBe(LOOP_THRESHOLD);
  });

  it("does not let a broken last frame excuse itself", () => {
    const frames = { ...moving(0, 100), last: frame(220) };
    expect(auditLoopSeam("piece", frames).map((entry) => entry.rule)).toEqual(["MEDIA-LOOP"]);
  });
});
