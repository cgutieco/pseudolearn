import { missingFrames, type FrameClock } from "../layout/frame_sampling.ts";
import { checkSafeArea, type FrameLayout, type SafeAreaRequest } from "../layout/safe_area_check.ts";
import { finding, type Finding } from "./finding.ts";

const LISTED_MISSING_FRAMES = 5;

export function auditSafeArea(target: string, request: SafeAreaRequest): readonly Finding[] {
  return checkSafeArea(request).map((violation) => finding("MEDIA-SAFE-AREA", target,
    `${violation.element} ${violation.reason} at ${violation.timeSeconds.toFixed(2)}s`));
}

export function auditFrameCoverage(target: string, clock: FrameClock, layout: readonly FrameLayout[]): readonly Finding[] {
  const missing = missingFrames(clock, layout);
  if (missing.length === 0) {
    return [];
  }
  const listed = missing.slice(0, LISTED_MISSING_FRAMES).join(", ");
  const more = missing.length > LISTED_MISSING_FRAMES ? ", …" : "";
  return [finding("MEDIA-SAFE-AREA", target, `layout misses ${missing.length} frames (${listed}${more}); every frame must be checked`)];
}
