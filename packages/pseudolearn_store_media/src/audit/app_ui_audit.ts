import { finding, type Finding } from "./finding.ts";

export type TimeSpan = { readonly startSeconds: number; readonly endSeconds: number };

export type Cover = TimeSpan & { readonly areaFraction: number };

export type AppUiRequest = {
  readonly target: string;
  readonly durationSeconds: number;
  readonly fps: number;
  readonly scenes: readonly TimeSpan[];
  readonly covers: readonly Cover[];
};

export const MINIMUM_VISIBLE_UI = 0.5;

export function visibleUiAt(request: AppUiRequest, seconds: number): number {
  const inScene = request.scenes.some((span) => seconds >= span.startSeconds && seconds < span.endSeconds);
  if (!inScene) {
    return 0;
  }
  const covered = request.covers
    .filter((cover) => seconds >= cover.startSeconds && seconds < cover.endSeconds)
    .reduce((total, cover) => total + cover.areaFraction, 0);
  return Math.max(0, 1 - covered);
}

export function auditAppUi(request: AppUiRequest): readonly Finding[] {
  const frameCount = Math.round(request.durationSeconds * request.fps);
  const failing: number[] = [];
  for (let frame = 0; frame < frameCount; frame += 1) {
    if (visibleUiAt(request, frame / request.fps) < MINIMUM_VISIBLE_UI) {
      failing.push(frame);
    }
  }
  return runsOf(failing).map(([first, last]) => finding("MEDIA-APP-UI", request.target,
    `frames ${first}–${last} (${(first / request.fps).toFixed(2)}s) show less than ${MINIMUM_VISIBLE_UI * 100}% of the app's interface`));
}

function runsOf(frames: readonly number[]): readonly (readonly [number, number])[] {
  const runs: [number, number][] = [];
  for (const frame of frames) {
    const current = runs[runs.length - 1];
    if (current && current[1] === frame - 1) {
      current[1] = frame;
    } else {
      runs.push([frame, frame]);
    }
  }
  return runs;
}
