import type { Slot } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";
import { hasAlphaChannel, hasTransparencyChunk, readPngHeader } from "./png_header.ts";

export type ImageAuditRequest = {
  readonly slot: Slot;
  readonly target: string;
  readonly bytes: Uint8Array;
};

export function auditImage(request: ImageAuditRequest): readonly Finding[] {
  const { slot, target, bytes } = request;
  const reading = readPngHeader(bytes);
  if (!reading.ok) {
    return [finding("MEDIA-FORMAT", target, reading.reason)];
  }
  const { header } = reading;
  const findings: Finding[] = [];
  if (header.width !== slot.width || header.height !== slot.height) {
    findings.push(finding("MEDIA-DIMENSIONS", target,
      `${header.width}×${header.height} instead of ${slot.width}×${slot.height}`));
  }
  if (hasAlphaChannel(header) || hasTransparencyChunk(bytes)) {
    findings.push(finding("MEDIA-ALPHA", target, "the image carries transparency"));
  }
  if (header.bitDepth !== 8) {
    findings.push(finding("MEDIA-FORMAT", target, `bit depth ${header.bitDepth} instead of 8`));
  }
  if (bytes.length > slot.maxBytes) {
    findings.push(finding("MEDIA-SIZE", target, `${bytes.length} bytes exceeds ${slot.maxBytes}`));
  }
  return findings;
}
