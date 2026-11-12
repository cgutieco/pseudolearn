import { describe, expect, it } from "vitest";
import { lensLayout } from "../../src/layout/lens_layout.ts";
import { lensStoryboard } from "../../src/pipeline/lens_storyboard.ts";
import { storyboardProblems } from "../../src/story/storyboard.ts";
import { slot } from "../support/catalog.ts";
import { shippedLensStory, SIMPLE_MEASURE } from "../support/lens.ts";

const story = shippedLensStory();
const kinds = story.statements.es.map((item) => item.kind);
const forms = { terminal: "box", io: "box", process: "box", decision: "tall", join: "dot" } as const;

function board(id: string) {
  const layout = lensLayout({ slot: slot(id), entries: story.statements.es.map((item) => ({ text: item.text, form: forms[item.kind] })), rhythm: story.rows, measure: SIMPLE_MEASURE });
  return lensStoryboard(layout, story, kinds);
}

describe("lensStoryboard", () => {
  it("plays one note per node that crosses the lens, valid for the header and the search slots", () => {
    for (const id of ["apple.header.video", "apple.search.video"]) {
      const storyboard = board(id);
      expect(storyboard.beats.length).toBeGreaterThan(8);
      expect(storyboardProblems(storyboard, slot(id))).toEqual([]);
    }
  });

  it("accents the loop condition and keeps the rest soft", () => {
    const beats = board("apple.header.video").beats;
    expect(beats.filter((beat) => beat.kind === "accent").every((beat) => beat.weight === 1)).toBe(true);
    expect(beats.filter((beat) => beat.kind === "step").every((beat) => beat.weight < 1)).toBe(true);
    expect(beats.some((beat) => beat.kind === "accent")).toBe(true);
  });

  it("stays inside the scale of the voice", () => {
    expect(Math.max(...board("apple.search.video").beats.map((beat) => beat.degree))).toBeLessThan(10);
  });
});
