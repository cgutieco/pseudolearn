import { checkSafeArea, type SafeAreaRequest } from "../layout/safe_area_check.ts";
import { finding, type Finding } from "./finding.ts";

export function auditSafeArea(target: string, request: SafeAreaRequest): readonly Finding[] {
  return checkSafeArea(request).map((violation) => finding("MEDIA-SAFE-AREA", target,
    `${violation.element} ${violation.reason} at ${violation.timeSeconds.toFixed(2)}s`));
}
