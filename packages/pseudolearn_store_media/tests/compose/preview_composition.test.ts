import { describe, expect, it } from "vitest";
import { buildPreviewComposition, plateFileOf } from "../../src/compose/preview_composition.ts";
import { planPreview } from "../../src/story/preview_plan.ts";
import { plateTimeline, previewStory } from "../support/preview.ts";

const narrow = (text: string, size: number): number => text.length * size * 0.5;
const preview = previewStory().previews[0]!;
const run = plateTimeline("preview-run", 10, [{ frame: 30, kind: "tap", point: { x: 400, y: 1700 } }]);
const nodo = plateTimeline("preview-nodo", 10);
const insets = { top: 124, right: 0, bottom: 68, left: 0 };

function compose(timelines = [run, nodo], language: "es" | "en" = "es") {
  return buildPreviewComposition({ id: "01-overview", plan: planPreview(preview, timelines), canvas: { width: 886, height: 1920 },
    insets, language, measure: narrow });
}

describe("buildPreviewComposition", () => {
  it("plays each plate at native size from its trim and dissolves the next one in", () => {
    const composition = compose();
    expect(composition.html).toContain(`src="${plateFileOf(0)}" muted data-start="0" data-duration="9"`);
    expect(composition.html).toContain(`data-start="8.4" data-duration="8"\n data-media-start="1"`);
    expect(composition.html).toContain("width:886px;height:1920px");
    expect(composition.html).toContain(`timeline.fromTo("#scene-1", { opacity: 0 }, { opacity: 1, duration: 0.6, ease: "none" }, 8.4);`);
    expect(composition.plates).toEqual([{ sceneIndex: 0, file: "plates/scene-0.mp4" }, { sceneIndex: 1, file: "plates/scene-1.mp4" }]);
  });

  it("writes the captions with their marks, fades them and reports their cover and size", () => {
    const composition = compose();
    expect(composition.html).toContain("cobra vida.</span>");
    expect(composition.html).toContain(`timeline.to("#caption-0", { opacity: 1, duration: 0.3, ease: "sine.out" }, 0.5);`);
    expect(composition.timedTexts.map((text) => text.text)).toEqual(["Tu programa\n*cobra vida.*", "Nodo requiere suscripción.", "Verificado"]);
    expect(composition.covers).toHaveLength(3);
    expect(composition.fits.map((entry) => entry.role)).toEqual(["caption-0 headline", "caption-1 disclosure"]);
  });

  it("anchors the pin on the recorded focus and draws a touch where the app was tapped", () => {
    const composition = compose([run, nodo], "en");
    expect(composition.html).toContain(">Checked<");
    expect(composition.html).toContain('id="touch-0"');
    expect(composition.missingFocus).toEqual([]);
    expect(composition.texts).toContain("Your program\n*comes alive.*");
  });

});

describe("buildPreviewComposition brand cards", () => {
  it("draws the brand cards with the disclosure and reports their cover and text", () => {
    const story = previewStory();
    const framed = buildPreviewComposition({ id: "01-overview", plan: planPreview(preview, [run, nodo], { brand: story.brand, disclosure: story.disclosure }),
      canvas: { width: 886, height: 1920 }, insets, language: "en", measure: narrow });
    expect(framed.html).toContain('id="card-opening"');
    expect(framed.html).toContain(">Nodo needs sign-in and a subscription.<");
    expect(framed.html).toContain(`timeline.set("#card-opening", { opacity: 1 }, 0);`);
    expect(framed.timedTexts.at(-1)?.text).toBe("Nodo needs sign-in and a subscription.");
    expect(framed.timedTexts.at(-1)?.startSeconds).toBeCloseTo(13.4);
    expect(framed.fits.at(-1)?.role).toBe("card-closing disclosure");
    expect(framed.covers).toHaveLength(compose([run, nodo], "en").covers.length + 2);
  });

  it("reports a pin whose focus the plate did not record", () => {
    const blind = { ...nodo, frames: nodo.frames.map((frame) => ({ ...frame, focus: [] })) };
    expect(compose([run, blind]).missingFocus).toEqual(["verified-code"]);
  });
});
