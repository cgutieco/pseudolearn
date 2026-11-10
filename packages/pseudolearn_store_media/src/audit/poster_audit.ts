import type { TimeSpan } from "./app_ui_audit.ts";
import { finding, type Finding } from "./finding.ts";

export type PosterText = { readonly text: string; readonly fontSize: number };

export type PosterRequest = {
  readonly target: string;
  readonly posterSeconds: number;
  readonly durationSeconds: number;
  readonly fps: number;
  readonly transitions: readonly TimeSpan[];
  readonly texts: readonly PosterText[];
  readonly canvasLongSide: number;
};

export const POSTER_PREVIEW_LONG_SIDE = 600;
export const MINIMUM_POSTER_TEXT_PIXELS = 11;

export function posterTextPixels(fontSize: number, canvasLongSide: number): number {
  return (fontSize * POSTER_PREVIEW_LONG_SIDE) / canvasLongSide;
}

export function auditPoster(request: PosterRequest): readonly Finding[] {
  const { target, posterSeconds } = request;
  const findings: Finding[] = [];
  if (posterSeconds < 0 || posterSeconds > request.durationSeconds - 1 / request.fps) {
    findings.push(finding("MEDIA-POSTER", target, `${posterSeconds}s is not a frame of a ${request.durationSeconds.toFixed(2)}s preview`));
  }
  if (request.transitions.some((span) => posterSeconds >= span.startSeconds && posterSeconds < span.endSeconds)) {
    findings.push(finding("MEDIA-POSTER", target, `${posterSeconds}s falls inside a dissolve, where two scenes blend`));
  }
  for (const text of request.texts) {
    const pixels = posterTextPixels(text.fontSize, request.canvasLongSide);
    if (pixels < MINIMUM_POSTER_TEXT_PIXELS) {
      findings.push(finding("MEDIA-POSTER", text.text,
        `would be ${pixels.toFixed(1)} px tall at ${POSTER_PREVIEW_LONG_SIDE} px, under ${MINIMUM_POSTER_TEXT_PIXELS} px`));
    }
  }
  return findings;
}
