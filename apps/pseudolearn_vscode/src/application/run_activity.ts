import type { RunState } from "../contracts/editor_run";

const activeStates: ReadonlySet<RunState> = new Set<RunState>(["starting", "running", "awaitingInput", "stopping"]);

export function isRunActive(state: RunState): boolean {
  return activeStates.has(state);
}
