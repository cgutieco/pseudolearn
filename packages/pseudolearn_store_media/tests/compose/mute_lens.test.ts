import { describe, expect, it } from "vitest";
import { auditContentRules } from "../../src/audit/content_rules_audit.ts";
import { auditSafeArea } from "../../src/audit/safe_area_audit.ts";
import { buildMuteLens } from "../../src/compose/mute_lens.ts";
import { muteLensLayout } from "../../src/layout/mute_lens_layout.ts";
import { toPixels } from "../../src/layout/pixel_rect.ts";
import { slot } from "../support/catalog.ts";
import { shippedLensStory } from "../support/lens.ts";

const story = shippedLensStory();

function pieceFor(id: string) {
  const target = slot(id);
  const canvas = { width: target.width, height: target.height };
  const statements = story.statements.es;
  const layout = muteLensLayout({ canvas, safeArea: toPixels(target.safeArea, canvas), lines: statements.map((entry) => entry.text), anchor: 3,
    measure: (text, size) => text.length * size * 0.6 });
  return { target, composition: buildMuteLens({ id: "hero", slot: target, layout, kinds: statements.map((entry) => entry.kind) }) };
}

describe("buildMuteLens", () => {
  it("shows code as letterless bars and the flowchart without labels, so the hero passes no-text and no-interface", () => {
    const { target, composition } = pieceFor("microsoft.hero-art");
    expect(composition.texts).toEqual([]);
    expect(composition.html).not.toContain("<text");
    expect(composition.html).toContain("rgba(242,144,69");
    expect(auditContentRules("hero", { slot: target, frames: composition.layout, texts: composition.texts, html: composition.html })).toEqual([]);
    expect(auditSafeArea("hero", { slot: target, frames: composition.layout, profiles: [] })).toEqual([]);
  });

  it("fits the poster and the box art inside their top two thirds", () => {
    for (const id of ["microsoft.poster-art", "microsoft.box-art"]) {
      const { target, composition } = pieceFor(id);
      expect(auditSafeArea(id, { slot: target, frames: composition.layout, profiles: [] })).toEqual([]);
      expect(auditContentRules(id, { slot: target, frames: composition.layout, texts: [], html: composition.html })).toEqual([]);
    }
  });
});
