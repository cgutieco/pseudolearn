import { describe, expect, it } from "vitest";
import { auditContrast } from "../../src/audit/text_audit.ts";
import { EDITORIAL_PALETTES, editorialContrastPairs } from "../../src/compose/editorial_palette.ts";
import { PALETTES } from "../../src/story/screenshot_story.ts";

describe("editorial palettes", () => {
  it("keep every text role legible on every chapter color", () => {
    for (const palette of PALETTES) {
      expect(auditContrast(editorialContrastPairs(EDITORIAL_PALETTES[palette])), palette).toEqual([]);
    }
  });

  it("check the headline against its marker too", () => {
    expect(editorialContrastPairs(EDITORIAL_PALETTES.sand).map((pair) => pair.role)).toContain("marked headline");
  });

  it("would be caught by the contrast audit with a pale label", () => {
    const pale = { ...EDITORIAL_PALETTES.mint, label: "#D7F1F2" };
    expect(auditContrast(editorialContrastPairs(pale)).map((entry) => entry.target)).toEqual(["chapter label"]);
  });
});
