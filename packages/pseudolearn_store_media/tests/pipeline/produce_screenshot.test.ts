import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { readGlyphAdvances } from "../../src/layout/glyph_advances.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceScreenshot, type LoadedFont, type ScreenshotJob } from "../../src/pipeline/produce_screenshot.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox, type FakeScript, type FakeToolbox } from "../support/fake_toolbox.ts";
import { recordMacNodo } from "../support/plates.ts";
import { pngBytes } from "../support/png.ts";
import { chapterOf, TEST_STORY } from "../support/story.ts";

function font(name: string): LoadedFont {
  const bytes = new Uint8Array(readFileSync(fileURLToPath(new URL(`../../../pseudolearn_brand/assets/fonts/${name}`, import.meta.url))));
  const reading = readGlyphAdvances(bytes);
  if (!reading.ok) {
    throw new Error(reading.reason);
  }
  return { bytes, advances: reading.advances };
}

const FONTS = { sans: font("IBMPlexSans-Bold.ttf"), mono: font("IBMPlexMono-Medium.ttf") };
const OUTPUT = "out/app-store/apple.mac.screenshot/es";

function setUp(script: FakeScript, overrides: Partial<ScreenshotJob> = {}): { toolbox: FakeToolbox; request: ScreenshotJob } {
  const catalog = realCatalog();
  const [job] = planJobs({ catalog, slotIds: ["apple.mac.screenshot"], languages: ["es"] }).jobs;
  if (!job) {
    throw new Error("fixture");
  }
  const toolbox = fakeToolbox(script, {} as VideoProbe);
  return { toolbox, request: { toolbox, catalog, job, story: TEST_STORY, chapter: chapterOf(TEST_STORY, "nodo"), position: 4,
    fonts: FONTS, platesRoot: "plates", outputRoot: "out", guides: false, ...overrides } };
}

describe("produceScreenshot", () => {
  it("composes, renders one frame, flattens it and accepts the opaque image", async () => {
    const { toolbox, request } = setUp({ flattened: pngBytes({ width: 2880, height: 1800, colorType: 2 }) });
    recordMacNodo(toolbox);
    const outcome = await produceScreenshot(request);
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    expect(outcome.ok && outcome.value.file).toBe(`${OUTPUT}/04-nodo.png`);
    for (const file of ["plate.png", "headline.ttf", "mono.ttf", "index.html"]) {
      expect(toolbox.written.has(`${OUTPUT}/projects/04-nodo/${file}`), file).toBe(true);
    }
    expect(toolbox.written.has(`${OUTPUT}/04-nodo.audit.json`)).toBe(true);
  });
});

describe("produceScreenshot rejections", () => {
  it("stops before rendering when the plate was never recorded", async () => {
    const { toolbox, request } = setUp({});
    const outcome = await produceScreenshot(request);
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-PLATE"]);
    expect(toolbox.renders).toEqual([]);
  });

  it("stops before rendering when the plate lacks the chapter's focus", async () => {
    const { toolbox, request } = setUp({});
    recordMacNodo(toolbox, "trace");
    const outcome = await produceScreenshot(request);
    expect(outcome.ok && outcome.value.findings[0]?.message).toBe("the plate did not record the focus verified-code; it has trace");
    expect(toolbox.renders).toEqual([]);
  });

  it("stops before rendering when a headline breaks the store lexicon", async () => {
    const chapter = { ...chapterOf(TEST_STORY, "nodo"), headline: { es: "Gratis en Android", en: "x" } };
    const { toolbox, request } = setUp({}, { chapter });
    recordMacNodo(toolbox);
    const outcome = await produceScreenshot(request);
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["TEXT-LEXICON", "TEXT-LEXICON"]);
    expect(toolbox.renders).toEqual([]);
  });

});

describe("produceScreenshot failures after rendering", () => {
  it("rejects a rendered image that still carries alpha", async () => {
    const { toolbox, request } = setUp({ flattened: pngBytes({ width: 2880, height: 1800, colorType: 6 }) });
    recordMacNodo(toolbox);
    const outcome = await produceScreenshot(request);
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-ALPHA"]);
  });

  it("surfaces a renderer or flattening failure as an error value", async () => {
    const failing = setUp({ frames: { ok: false, error: "browser crashed" } });
    recordMacNodo(failing.toolbox);
    expect(await produceScreenshot(failing.request)).toEqual({ ok: false, error: "browser crashed" });
    const flattening = setUp({ flatten: { ok: false, error: "ffmpeg failed" } });
    recordMacNodo(flattening.toolbox);
    expect(await produceScreenshot(flattening.request)).toEqual({ ok: false, error: "ffmpeg failed" });
  });

  it("refuses a slot without a device", async () => {
    const [job] = planJobs({ catalog: realCatalog(), slotIds: ["microsoft.hero-art"], languages: ["en"] }).jobs;
    const { request } = setUp({}, job ? { job } : {});
    expect(await produceScreenshot(request)).toEqual({ ok: false, error: "microsoft.hero-art declares no device to frame the plate in" });
  });
});
