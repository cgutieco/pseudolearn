import type { Beat, Storyboard } from "./storyboard.ts";
import { traceEndSeconds, type ThermostatStory } from "./thermostat_story.ts";

const LINE_DEGREES = [0, 2, 4, 5, 4, 2, 0, 4, 2, 1];
export const CLOSING_DELAY = 1.2;

export function thermostatStoryboard(story: ThermostatStory): Storyboard {
  const steps: Beat[] = story.trace.map((step, index) => ({
    atSeconds: story.startSeconds + index * story.stepSeconds,
    kind: step.condition ? "accent" : step.output !== null ? "reveal" : "step",
    degree: LINE_DEGREES[step.line % LINE_DEGREES.length] ?? 0,
    weight: step.condition ? 0.9 : 0.6,
  }));
  const end = traceEndSeconds(story);
  return {
    id: story.id,
    durationSeconds: story.durationSeconds,
    beats: [
      ...steps,
      { atSeconds: end + CLOSING_DELAY, kind: "reveal", degree: 4, weight: 0.8 },
      { atSeconds: story.interface.startSeconds, kind: "step", degree: 2, weight: 0.5 },
      { atSeconds: story.lockupSeconds, kind: "resolve", degree: 0, weight: 1 },
    ],
  };
}
