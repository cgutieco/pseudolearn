import type { Slot } from "../catalog/catalog_types.ts";

export const BEAT_KINDS = ["step", "accent", "reveal", "resolve"] as const;
export type BeatKind = (typeof BEAT_KINDS)[number];

export type Beat = {
  readonly atSeconds: number;
  readonly kind: BeatKind;
  readonly degree: number;
  readonly weight: number;
};

export type Storyboard = {
  readonly id: string;
  readonly durationSeconds: number;
  readonly beats: readonly Beat[];
};

export function storyboardProblems(storyboard: Storyboard, slot: Slot): readonly string[] {
  const problems: string[] = [];
  const range = slot.video?.duration;
  if (!range) {
    problems.push(`${slot.id} is not a video slot`);
  } else if (storyboard.durationSeconds < range.min || storyboard.durationSeconds > range.max) {
    problems.push(`duration ${storyboard.durationSeconds}s is outside ${range.min}–${range.max}s`);
  }
  storyboard.beats.forEach((beat, index) => {
    if (beat.atSeconds < 0 || beat.atSeconds >= storyboard.durationSeconds) {
      problems.push(`beat ${index} at ${beat.atSeconds}s falls outside the storyboard`);
    }
    if (beat.weight <= 0 || beat.weight > 1) {
      problems.push(`beat ${index} weight must be in (0, 1]`);
    }
    const previous = storyboard.beats[index - 1];
    if (previous && previous.atSeconds > beat.atSeconds) {
      problems.push(`beat ${index} is out of order`);
    }
  });
  return problems;
}
