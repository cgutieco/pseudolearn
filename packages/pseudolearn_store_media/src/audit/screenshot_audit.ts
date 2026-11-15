import type { Device } from "../catalog/catalog_types.ts";
import type { HeadlineFit } from "../layout/headline_fit.ts";
import { finding, type Finding } from "./finding.ts";
import { readPngHeader } from "./png_header.ts";

export function auditHeadlineFit(target: string, fit: HeadlineFit): readonly Finding[] {
  if (fit.fits) {
    return [];
  }
  return [finding("TEXT-FIT", target,
    `${fit.overflowingLines.map((line) => `"${line}"`).join(", ")} does not fit at the minimum size of ${fit.fontSize.toFixed(0)}px`)];
}

export function auditPlate(target: string, device: Device, bytes: Uint8Array | null): readonly Finding[] {
  if (bytes === null) {
    return [finding("MEDIA-PLATE", target, "the plate was not recorded; run the app's plate generator first")];
  }
  const reading = readPngHeader(bytes);
  if (!reading.ok) {
    return [finding("MEDIA-PLATE", target, reading.reason)];
  }
  const width = device.logicalWidth * device.plateScale;
  const height = device.logicalHeight * device.plateScale;
  const { header } = reading;
  return header.width === width && header.height === height
    ? []
    : [finding("MEDIA-PLATE", target, `${header.width}×${header.height} instead of ${width}×${height} for ${device.id}`)];
}

export function auditFocus(target: string, wanted: string | null, recorded: readonly string[] | null): readonly Finding[] {
  if (wanted === null) {
    return [];
  }
  if (recorded === null) {
    return [finding("MEDIA-PLATE", target, "the plate has no readable timeline.json with focus rectangles")];
  }
  return recorded.includes(wanted) ? [] : [finding("MEDIA-PLATE", target, `the plate did not record the focus ${wanted}; it has ${recorded.join(", ") || "none"}`)];
}
