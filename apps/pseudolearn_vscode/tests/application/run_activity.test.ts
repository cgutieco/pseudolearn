import { describe, expect, it } from "vitest";
import { isRunActive } from "../../src/application/run_activity";
import type { RunState } from "../../src/contracts/editor_run";

describe("isRunActive", () => {
  it("treats every state that a stop request can still affect as active", () => {
    const states: RunState[] = ["starting", "running", "awaitingInput", "stopping"];
    expect(states.map(isRunActive)).toEqual([true, true, true, true]);
  });

  it("treats idle and every concluded state as inactive", () => {
    const states: RunState[] = ["idle", "finished", "aborted", "serverDown"];
    expect(states.map(isRunActive)).toEqual([false, false, false, false]);
  });
});
