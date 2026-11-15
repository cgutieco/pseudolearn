import { describe, expect, it } from "vitest";
import { auditContrast } from "../../src/audit/text_audit.ts";
import { settingClockTimeline } from "../../src/compose/composition.ts";
import { buildLensComposition } from "../../src/compose/lens_composition.ts";
import { lensContrastPairs } from "../../src/compose/lens_palette.ts";
import { slot } from "../support/catalog.ts";
import { shippedLensStory, SIMPLE_MEASURE } from "../support/lens.ts";

const story = shippedLensStory();

function piece(id: string, language: "es" | "en" = "es") {
  return buildLensComposition({ slot: slot(id), story, language, measure: SIMPLE_MEASURE });
}

describe("buildLensComposition", () => {
  it("animates the header with a clock that renders on every seek", () => {
    const { composition } = piece("apple.header.video");
    expect(composition.id).toBe("lens-apple-header-video-es");
    expect(composition.durationSeconds).toBe(20);
    expect(composition.html).toContain(settingClockTimeline(20));
    expect(composition.layout).toHaveLength(600);
  });

  it("freezes the universal image on one moment and checks one layout", () => {
    const { composition } = piece("apple.universal.image");
    expect(composition.durationSeconds).toBe(1);
    expect(composition.html).not.toContain("set t(value)");
    expect(composition.html).toMatch(/render\([\d.]+\);/u);
    expect(composition.layout).toHaveLength(1);
  });

  it("draws the river outside and the diagram inside the lens", () => {
    const { composition, layout } = piece("apple.search.video");
    expect(composition.html.match(/class="code"/gu)!.length).toBeGreaterThan(layout.rows.length);
    expect(composition.html).toContain('class="node decision"');
    expect(composition.html).toContain('class="node join"');
    expect(composition.html).toContain("Mientras temperatura &gt; 24 Hacer");
  });

  it("tells the story in English for the en piece and lists its texts for the lexicon", () => {
    const { composition } = piece("apple.header.video", "en");
    expect(composition.html).toContain("while temperature &gt; 24 do");
    expect(composition.html).not.toContain("Mientras");
    expect(composition.texts).toEqual(story.statements.en.map((item) => item.text));
  });

  it("marks the lens as the only essential element", () => {
    const { composition, layout } = piece("apple.header.video");
    expect(composition.layout[0]?.elements).toEqual([{ name: "lens", rect: layout.lens, essential: true }]);
  });
});

describe("lens palette", () => {
  it("keeps every node label legible", () => {
    expect(auditContrast(lensContrastPairs())).toEqual([]);
  });
});
