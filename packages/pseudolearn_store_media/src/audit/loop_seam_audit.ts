import { finding, type Finding } from "./finding.ts";
import { LOOP_THRESHOLD, meanAbsoluteDifference } from "./loop_audit.ts";

export const SEAM_MOTION_FACTOR = 2;

export type SeamFrames = {
  readonly first: Uint8Array;
  readonly second: Uint8Array;
  readonly third: Uint8Array;
  readonly antepenultimate: Uint8Array;
  readonly penultimate: Uint8Array;
  readonly last: Uint8Array;
};

export function seamAllowance(frames: SeamFrames): number {
  const motion = Math.max(
    meanAbsoluteDifference(frames.second, frames.third),
    meanAbsoluteDifference(frames.antepenultimate, frames.penultimate),
  );
  return Math.max(LOOP_THRESHOLD, SEAM_MOTION_FACTOR * motion);
}

export function auditLoopSeam(target: string, frames: SeamFrames): readonly Finding[] {
  const seam = meanAbsoluteDifference(frames.last, frames.first);
  const allowance = seamAllowance(frames);
  return seam <= allowance
    ? []
    : [finding("MEDIA-LOOP", target, `the loop seam differs by ${seam.toFixed(4)}, more than the ${allowance.toFixed(4)} its own motion allows`)];
}
