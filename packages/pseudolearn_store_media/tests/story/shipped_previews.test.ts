import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { auditLexicon } from "../../src/audit/text_audit.ts";
import { auditReadingTime } from "../../src/audit/preview_timing_audit.ts";
import { planPreview } from "../../src/story/preview_plan.ts";
import { parsePreviewStory, type PreviewStory } from "../../src/story/preview_story.ts";
import { realCatalog } from "../support/catalog.ts";
import { plateTimeline } from "../support/preview.ts";

function shipped(): PreviewStory {
  const parsed = parsePreviewStory(JSON.parse(readFileSync(new URL("../../stories/app-store-previews.json", import.meta.url), "utf8")));
  if (!parsed.ok) {
    throw new Error(JSON.stringify(parsed.errors));
  }
  return parsed.value;
}

const story = shipped();
const plans = story.previews.map((preview) => planPreview(preview,
  preview.scenes.map((scene) => plateTimeline(scene.plate, scene.toSeconds)), { brand: story.brand, disclosure: story.disclosure }));

describe("the shipped app preview story", () => {
  it("tells three previews of 15 to 30 seconds, the first one a summary", () => {
    expect(story.previews.map((preview) => preview.id)).toEqual(["overview", "run-and-understand", "nodo-code-route"]);
    for (const plan of plans) {
      expect(plan.durationSeconds).toBeGreaterThanOrEqual(15);
      expect(plan.durationSeconds).toBeLessThanOrEqual(30);
    }
  });

  it("closes every preview that shows Nodo with the disclosure on the brand card", () => {
    for (const plan of plans) {
      const closing = plan.cards.find((card) => card.item.kind === "closing");
      expect(closing?.item.disclosure !== null).toBe(plan.needsDisclosure);
    }
    expect(plans.map((plan) => plan.needsDisclosure)).toEqual([true, false, true]);
  });

  it("keeps every caption on screen long enough and inside its scene", () => {
    for (const language of ["es", "en"] as const) {
      for (const plan of plans) {
        const spans = plan.captions.map((caption) => ({ text: caption.item.text[language], startSeconds: caption.startSeconds,
          endSeconds: caption.endSeconds, sceneStartSeconds: plan.scenes[caption.sceneIndex]!.startSeconds,
          sceneEndSeconds: plan.scenes[caption.sceneIndex]!.endSeconds }));
        expect(auditReadingTime(spans)).toEqual([]);
      }
    }
  });

  it("uses no word the App Store lexicon forbids", () => {
    const texts = story.previews.flatMap((preview) => preview.scenes.flatMap((scene) =>
      [...scene.captions.map((caption) => caption.text), ...scene.pins.map((pin) => pin.note)]));
    const all = [...texts, story.disclosure!.text].flatMap((text) => [text.es, text.en]);
    expect(auditLexicon(realCatalog(), "app-store", all)).toEqual([]);
  });
});
