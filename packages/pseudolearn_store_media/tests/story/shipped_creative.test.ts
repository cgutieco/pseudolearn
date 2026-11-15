import { describe, expect, it } from "vitest";
import { auditLensLabels, auditLensRows } from "../../src/audit/lens_audit.ts";
import { auditLexicon } from "../../src/audit/text_audit.ts";
import { buildLensComposition } from "../../src/compose/lens_composition.ts";
import { textWidth } from "../../src/layout/glyph_advances.ts";
import { checkSafeArea } from "../../src/layout/safe_area_check.ts";
import { realCatalog, slot } from "../support/catalog.ts";
import { brandFont, shippedLensStory } from "../support/lens.ts";

const sans = brandFont("IBMPlexSans-Bold.ttf");
const mono = brandFont("IBMPlexMono-Medium.ttf");
const measure = { sans: (text: string, size: number) => textWidth(sans.advances, text, size), mono: (text: string, size: number) => textWidth(mono.advances, text, size) };

describe("shipped creative story", () => {
  it("fits, stays clear of every device crop and passes the lexicon in each slot and language", () => {
    const catalog = realCatalog();
    for (const id of ["apple.header.video", "apple.search.video", "apple.universal.image"]) {
      for (const language of ["es", "en"] as const) {
        const target = slot(id);
        const { composition, layout } = buildLensComposition({ slot: target, story: shippedLensStory(), language, measure });
        expect(auditLensLabels(id, layout, measure.sans), `${id} ${language}`).toEqual([]);
        expect(auditLensRows(id, layout)).toEqual([]);
        expect(checkSafeArea({ slot: target, frames: composition.layout.slice(0, 1), profiles: target.viewportProfiles })).toEqual([]);
        expect(auditLexicon(catalog, "app-store", composition.texts)).toEqual([]);
      }
    }
  });
});

describe("shipped creative statements", () => {
  it("are lines of the guided demo the app ships and runs, verbatim", async () => {
    const { readFileSync } = await import("node:fs");
    const story = shippedLensStory();
    for (const language of ["es", "en"] as const) {
      const demo = readFileSync(new URL(`../../../../apps/pseudolearn_app/assets/demo/guided_demo_${language}.pseudo`, import.meta.url), "utf8")
        .split("\n").map((line) => line.trim());
      for (const statement of story.statements[language]) {
        expect(demo, `${language}: ${statement.text}`).toContain(statement.text);
      }
    }
  });
});
