import type { Slot } from "../catalog/catalog_types.ts";
import type { Beat, Storyboard } from "./storyboard.ts";

const BEATS_PER_SECOND = 0.5;
const DEGREE_WALK = [0, 2, 4, 5, 4, 2, 7, 4];

export function calibrationStoryboard(slot: Slot): Storyboard {
  const durationSeconds = slot.video?.duration.min ?? 0;
  const count = Math.floor(durationSeconds * BEATS_PER_SECOND);
  const beats: Beat[] = [];
  for (let index = 0; index < count; index += 1) {
    const isLast = index === count - 1;
    beats.push({
      atSeconds: (index + 0.5) / BEATS_PER_SECOND,
      kind: isLast ? "resolve" : index % 4 === 0 ? "accent" : "step",
      degree: DEGREE_WALK[index % DEGREE_WALK.length] ?? 0,
      weight: isLast || index % 4 === 0 ? 1 : 0.6,
    });
  }
  return { id: `calibration-${slot.id}`, durationSeconds, beats };
}
