import { describe, expect, it } from "vitest";
import { buildEditorialScreenshot, PLATE_FILE, type EditorialRequest } from "../../src/compose/editorial_screenshot.ts";
import { MONO_FONT_FILE, SANS_FONT_FILE } from "../../src/compose/editorial_markup.ts";
import type { Chapter } from "../../src/story/screenshot_story.ts";
import { slot } from "../support/catalog.ts";
import { chapterOf, TEST_STORY } from "../support/story.ts";

const narrow = (text: string, size: number): number => text.length * size * 0.5;

function request(id: string, chapter: Chapter, overrides: Partial<EditorialRequest> = {}): EditorialRequest {
  const target = slot(id);
  if (!target.device) {
    throw new Error(id);
  }
  const plate = { width: target.device.logicalWidth * target.device.plateScale, height: target.device.logicalHeight * target.device.plateScale };
  return { slot: target, device: target.device, chapter, position: 4, language: "es", texture: TEST_STORY.texture.es,
    focus: { x: 40, y: 400, width: 600, height: 300 }, plate, measures: { sans: narrow, mono: narrow }, guides: false, ...overrides };
}

const nodo = chapterOf(TEST_STORY, "nodo");
const manifesto = chapterOf(TEST_STORY, "language");

describe("buildEditorialScreenshot", () => {
  it("writes the marked headline, the chapter number, the note and both faces", () => {
    const composition = buildEditorialScreenshot(request("apple.iphone.screenshot", nodo));
    expect(composition.html).toContain('<span class="hl">escribe.</span>');
    expect(composition.html).toContain(">04<");
    expect(composition.html).toContain(">Verificado<");
    expect(composition.html).toContain(`url('${PLATE_FILE}')`);
    expect(composition.html).toContain(`url("${SANS_FONT_FILE}")`);
    expect(composition.html).toContain(`url("${MONO_FONT_FILE}")`);
    expect(composition.fits.map((entry) => entry.role)).toEqual(["note", "headline"]);
  });

  it("lists every visible text for the lexicon, the texture included", () => {
    const composition = buildEditorialScreenshot(request("apple.iphone.screenshot", nodo));
    expect(composition.texts).toEqual(["Mientras x > 0 Hacer", "Verificado", "Nodo escribe."]);
  });

  it("declares the texts essential and the bleeding device clipped to the canvas", () => {
    const composition = buildEditorialScreenshot(request("apple.iphone.screenshot", nodo));
    const elements = composition.layout[0]?.elements ?? [];
    const device = elements.find((element) => element.name === "device");
    expect(elements.filter((element) => element.essential).map((element) => element.name)).toEqual(["note", "headline", "label"]);
    expect((device?.rect.y ?? 0) + (device?.rect.height ?? 0)).toBeLessThanOrEqual(2868);
  });

  it("composes a manifesto with subline and colored code but no chapter number", () => {
    const composition = buildEditorialScreenshot(request("apple.mac.screenshot", manifesto));
    expect(composition.html).toContain('<span class="kw">Proceso</span>');
    expect(composition.html).toContain('<span class="lit">&quot;Hola&quot;</span>');
    expect(composition.html).not.toContain(">04<");
    expect(composition.fits.map((entry) => entry.role)).toEqual(["headline", "subline", "code"]);
  });

  it("folds the inner Duo into two halves", () => {
    const html = buildEditorialScreenshot(request("apple.iphone-duo-inner.screenshot.landscape", nodo)).html;
    expect(html).toContain("rotateY(10deg)");
    expect(html).toContain("rotateY(-10deg)");
    expect(buildEditorialScreenshot(request("apple.iphone-duo-inner.screenshot.portrait", nodo)).html).toContain("rotateX(");
  });
});

describe("buildEditorialScreenshot rejections", () => {
  it("reports a headline that cannot fit", () => {
    const wide = (text: string, size: number): number => text.length * size * 20;
    const composition = buildEditorialScreenshot(request("apple.iphone-duo-outer.screenshot.portrait", nodo, { measures: { sans: wide, mono: wide } }));
    expect(composition.fits.some((entry) => !entry.fit.fits)).toBe(true);
  });

  it("drops the note and highlight when the plate recorded no focus", () => {
    const composition = buildEditorialScreenshot(request("apple.ipad.screenshot", nodo, { focus: null }));
    expect(composition.html).not.toContain(">Verificado<");
    expect(composition.fits.map((entry) => entry.role)).toEqual(["headline"]);
  });

  it("escapes markup and draws the margin guide on request", () => {
    const hostile = { ...nodo, headline: { es: "<b>&</b>", en: "x" } };
    const composition = buildEditorialScreenshot(request("apple.mac.screenshot", hostile, { guides: true }));
    expect(composition.html).toContain("&lt;b&gt;&amp;&lt;/b&gt;");
    expect(composition.html).toContain("dashed");
  });
});
