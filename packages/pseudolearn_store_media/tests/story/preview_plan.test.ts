import { describe, expect, it } from "vitest";
import { planPreview, plateSecondsAt, previewStoryboard, scenesAt, TOUCH_SECONDS } from "../../src/story/preview_plan.ts";
import { plateTimeline, previewStory } from "../support/preview.ts";

const preview = previewStory().previews[0]!;
const run = plateTimeline("preview-run", 10, [
  { frame: 30, kind: "tap", point: { x: 400, y: 1700 } },
  { frame: 45, kind: "diagram-node", point: null },
  { frame: 290, kind: "completion", point: null },
]);
const nodo = plateTimeline("preview-nodo", 10, [
  { frame: 15, kind: "tap", point: { x: 800, y: 1800 } },
  { frame: 120, kind: "agent-message", point: null },
]);
const plan = planPreview(preview, [run, nodo]);

describe("planPreview", () => {
  it("overlaps each scene with the previous one by its dissolve", () => {
    expect(plan.scenes.map((scene) => [scene.startSeconds, scene.endSeconds])).toEqual([[0, 9], [8.4, 16.4]]);
    expect(plan.durationSeconds).toBeCloseTo(16.4);
    expect(scenesAt(plan, 8.5)).toHaveLength(2);
    expect(scenesAt(plan, 16.4)).toEqual([]);
  });

  it("maps preview time to the trimmed plate time", () => {
    expect(plateSecondsAt(plan.scenes[1]!, 8.4)).toBe(1);
    expect(plateSecondsAt(plan.scenes[1]!, 10)).toBeCloseTo(2.6);
  });

  it("places overlays in preview time", () => {
    expect(plan.captions.map((caption) => [caption.startSeconds, caption.endSeconds])).toEqual([[0.5, 5], [13.4, 16.4]]);
    expect(plan.pins[0]).toMatchObject({ sceneIndex: 1, startSeconds: 9.4 });
  });

  it("draws touches only for scenes that ask for them and only inside the trim", () => {
    expect(plan.touches).toEqual([{ sceneIndex: 0, startSeconds: 1, endSeconds: 1 + TOUCH_SECONDS, item: { x: 400, y: 1700 } }]);
  });

  it("anchors the score to scene entrances and to the milestones the app recorded inside each trim", () => {
    const beats = previewStoryboard(plan).beats;
    expect(beats.map((beat) => [Number(beat.atSeconds.toFixed(2)), beat.kind])).toEqual([
      [0, "accent"], [1, "step"], [1.5, "accent"], [8.4, "accent"], [11.4, "reveal"],
    ]);
    expect(previewStoryboard(plan).durationSeconds).toBeCloseTo(16.4);
  });

});

describe("planPreview brand cards", () => {
  it("opens and closes with brand cards and puts the disclosure on the closing one when Nodo appears", () => {
    const story = previewStory();
    const framed = planPreview(preview, [run, nodo], { brand: story.brand, disclosure: story.disclosure });
    expect(framed.needsDisclosure).toBe(true);
    expect(framed.cards.map((card) => [card.item.kind, Number(card.startSeconds.toFixed(2)), Number(card.endSeconds.toFixed(2)), card.item.disclosure?.es ?? null])).toEqual([
      ["opening", 0, 2, null],
      ["closing", 13.4, 16.4, "Nodo requiere sesión y suscripción."],
    ]);
  });

  it("closes without a disclosure when no scene needs one, and draws no cards without a brand", () => {
    const story = previewStory();
    const quiet = { ...preview, scenes: [preview.scenes[0]!] };
    const framed = planPreview(quiet, [run], { brand: story.brand, disclosure: story.disclosure });
    expect(framed.needsDisclosure).toBe(false);
    expect(framed.cards[1]?.item.disclosure).toBeNull();
    expect(plan.cards).toEqual([]);
  });

  it("stops at a scene whose plate is missing and plans nothing for no plates", () => {
    expect(planPreview(preview, [run]).scenes).toHaveLength(1);
    const empty = planPreview(preview, []);
    expect([empty.durationSeconds, empty.beats.length, empty.captions.length]).toEqual([0, 0, 0]);
  });
});
