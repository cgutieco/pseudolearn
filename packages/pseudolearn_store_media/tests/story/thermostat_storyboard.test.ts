import { describe, expect, it } from "vitest";
import { storyboardProblems } from "../../src/story/storyboard.ts";
import { thermostatStoryboard } from "../../src/story/thermostat_storyboard.ts";
import { slot } from "../support/catalog.ts";
import { shippedThermostat } from "../support/thermostat.ts";

describe("thermostatStoryboard", () => {
  it("plays one note per executed step, accents the loop condition and resolves on the lockup", () => {
    const story = shippedThermostat();
    const board = thermostatStoryboard(story);
    expect(board.beats).toHaveLength(story.trace.length + 3);
    expect(board.beats.filter((beat) => beat.kind === "accent")).toHaveLength(3);
    expect(board.beats.at(-1)).toMatchObject({ atSeconds: story.lockupSeconds, kind: "resolve" });
    expect(storyboardProblems(board, slot("microsoft.trailer"))).toEqual([]);
  });

  it("reports a trailer shorter than the slot allows", () => {
    const story = { ...shippedThermostat(), durationSeconds: 10, lockupSeconds: 9 };
    expect(storyboardProblems(thermostatStoryboard(story), slot("microsoft.trailer"))).toContain("duration 10s is outside 15–60s");
  });
});
