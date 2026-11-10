import type { LensLayout } from "../layout/lens_layout.ts";
import { lensCrossings } from "../layout/lens_crossings.ts";
import type { LensStory, StatementKind } from "../story/lens_story.ts";
import type { Beat, Storyboard } from "../story/storyboard.ts";

const DEGREES: Readonly<Record<StatementKind, number>> = { terminal: 0, io: 2, process: 4, decision: 6, join: 5 };
const RUNNING_WEIGHT = 0.55;
const ROW_REGISTERS = 3;

export function lensStoryboard(layout: LensLayout, story: LensStory, kinds: readonly StatementKind[]): Storyboard {
  const lensRows = layout.rows.map((row, index) => (row.inLens ? index : -1)).filter((index) => index >= 0);
  const beats: Beat[] = lensCrossings(layout, story.durationSeconds).map((crossing) => {
    const kind = kinds[crossing.statement] ?? "process";
    return {
      atSeconds: Math.min(Number(crossing.atSeconds.toFixed(3)), story.durationSeconds - 0.001),
      kind: kind === "decision" ? "accent" : "step",
      degree: DEGREES[kind] + (Math.max(0, lensRows.indexOf(crossing.row)) % ROW_REGISTERS),
      weight: kind === "decision" ? 1 : RUNNING_WEIGHT,
    };
  });
  return { id: story.id, durationSeconds: story.durationSeconds, beats: beats.sort((first, second) => first.atSeconds - second.atSeconds) };
}
