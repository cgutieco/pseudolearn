import { describe, expect, it } from "vitest";
import { headlineRuns, plainLines } from "../../src/story/headline_runs.ts";

describe("headlineRuns", () => {
  it("marks the emphasized words, also across a line break", () => {
    expect(headlineRuns("Mira *pensar\na tu* programa")).toEqual([
      [{ text: "Mira ", marked: false }, { text: "pensar", marked: true }],
      [{ text: "a tu", marked: true }, { text: " programa", marked: false }],
    ]);
  });

  it("keeps a headline without emphasis as plain runs", () => {
    expect(headlineRuns("Hola")).toEqual([[{ text: "Hola", marked: false }]]);
    expect(plainLines("*Hola*\nmundo")).toEqual(["Hola", "mundo"]);
  });
});

describe("headlineRuns rejections", () => {
  it("rejects an unpaired mark", () => {
    expect(headlineRuns("a *b")).toBeNull();
  });

  it("returns an empty line for a blank line so the story can reject it", () => {
    expect(headlineRuns("a\n\nb")?.[1]).toEqual([]);
  });
});
