import type { FrameLayout, PlacedElement } from "./safe_area_check.ts";

export type FrameClock = { readonly durationSeconds: number; readonly fps: number };

const TIME_TOLERANCE = 1e-6;

export function frameCount(clock: FrameClock): number {
  return Math.round(clock.durationSeconds * clock.fps);
}

export function frameTime(clock: FrameClock, index: number): number {
  return index / clock.fps;
}

export function sampleEveryFrame(clock: FrameClock, elementsAt: (timeSeconds: number) => readonly PlacedElement[]): readonly FrameLayout[] {
  return Array.from({ length: frameCount(clock) }, (_unused, index) => {
    const timeSeconds = frameTime(clock, index);
    return { timeSeconds, elements: elementsAt(timeSeconds) };
  });
}

export function missingFrames(clock: FrameClock, layout: readonly FrameLayout[]): readonly number[] {
  const missing: number[] = [];
  const times = layout.map((frame) => frame.timeSeconds);
  for (let index = 0; index < frameCount(clock); index += 1) {
    const expected = frameTime(clock, index);
    if (!times.some((time) => Math.abs(time - expected) < TIME_TOLERANCE)) {
      missing.push(index);
    }
  }
  return missing;
}
