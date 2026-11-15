import type { LoudnessTarget } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";

export const LOOP_THRESHOLD = 0.005;

export function meanAbsoluteDifference(first: Uint8Array, second: Uint8Array): number {
  if (first.length !== second.length || first.length === 0) {
    return 1;
  }
  let total = 0;
  for (let index = 0; index < first.length; index += 1) {
    total += Math.abs((first[index] ?? 0) - (second[index] ?? 0));
  }
  return total / (first.length * 255);
}

export function auditLoop(target: string, firstFrame: Uint8Array, lastFrame: Uint8Array): readonly Finding[] {
  const difference = meanAbsoluteDifference(firstFrame, lastFrame);
  return difference <= LOOP_THRESHOLD
    ? []
    : [finding("MEDIA-LOOP", target, `first and last frames differ by ${difference.toFixed(4)} (limit ${LOOP_THRESHOLD})`)];
}

export type LoudnessMeasure = { readonly integratedLufs: number; readonly truePeakDb: number };

export function auditLoudness(target: string, measure: LoudnessMeasure, expected: LoudnessTarget): readonly Finding[] {
  const findings: Finding[] = [];
  if (Math.abs(measure.integratedLufs - expected.integratedLufs) > expected.toleranceLu) {
    findings.push(finding("MEDIA-LOUDNESS", target,
      `${measure.integratedLufs.toFixed(1)} LUFS instead of ${expected.integratedLufs} ± ${expected.toleranceLu}`));
  }
  if (measure.truePeakDb > expected.truePeakDb) {
    findings.push(finding("MEDIA-LOUDNESS", target, `true peak ${measure.truePeakDb.toFixed(1)} dBTP exceeds ${expected.truePeakDb}`));
  }
  return findings;
}
