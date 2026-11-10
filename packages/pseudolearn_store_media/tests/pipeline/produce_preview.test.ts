import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { CALIBRATION_VOICE } from "../../src/audio/score.ts";
import { readGlyphAdvances } from "../../src/layout/glyph_advances.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { producePreview } from "../../src/pipeline/produce_preview.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import type { PlateTimeline } from "../../src/story/plate_timeline.ts";
import type { Preview } from "../../src/story/preview_story.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox, type FakeScript, type FakeToolbox } from "../support/fake_toolbox.ts";
import { plateTimeline, previewStory } from "../support/preview.ts";
import { goodProbe } from "../support/probe.ts";

const catalog = realCatalog();
const fontBytes = new Uint8Array(readFileSync(new URL("../../../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf", import.meta.url)));
const reading = readGlyphAdvances(fontBytes);
const font = { bytes: fontBytes, advances: reading.ok ? reading.advances : ({} as never) };
const story = previewStory();
const preview = story.previews[0]!;
const frame = { brand: story.brand, disclosure: story.disclosure };

function recordPlates(toolbox: FakeToolbox, timelines: readonly PlateTimeline[], theme = ["light", "dark"]): void {
  timelines.forEach((timeline, index) => {
    toolbox.written.set(`plates/${timeline.scene}/iphone-preview/${theme[index]}/es/timeline.json`, new TextEncoder().encode(JSON.stringify(timeline)));
  });
}

type RunOptions = { script?: FakeScript; timelines?: readonly PlateTimeline[]; story?: Preview; frame?: typeof frame };

async function run(options: RunOptions = {}) {
  const [job] = planJobs({ catalog, slotIds: ["apple.iphone.app-preview"], languages: ["es"] }).jobs;
  const toolbox = fakeToolbox(options.script ?? {}, goodProbe({ width: 886, height: 1920 }, { durationSeconds: 16.4 }));
  recordPlates(toolbox, options.timelines ?? [plateTimeline("preview-run", 10), plateTimeline("preview-nodo", 10)]);
  const outcome = await producePreview({ toolbox, catalog, job: job!, preview: options.story ?? preview, frame: options.frame ?? frame, position: 1, font,
    voice: CALIBRATION_VOICE, platesRoot: "plates", outputRoot: "out" });
  return { toolbox, outcome };
}

describe("producePreview", () => {
  it("assembles each plate, renders, scores, encodes, extracts the poster and accepts the file", async () => {
    const { toolbox, outcome } = await run();
    expect(outcome.ok && outcome.value.findings).toEqual([]);
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    const base = "out/app-store/apple.iphone.app-preview/es/01-overview";
    expect(toolbox.written.get(`${base}/project/plates/scene-0.mp4`)).toEqual(new Uint8Array([300]));
    expect(toolbox.written.has(`${base}/project/headline.ttf`)).toBe(true);
    expect(toolbox.written.get(`${base}/01-overview.poster-600.png`)).toEqual(new Uint8Array([600 % 256]));
    expect(toolbox.written.has(`${base}/01-overview.poster.png`)).toBe(true);
    expect(toolbox.encodes[0]?.profile.rateControl).toBe("cbr");
    expect(toolbox.written.has(`${base}/01-overview.audit.json`)).toBe(true);
  });

  it("refuses to render when a plate would be scaled or the preview is too short", async () => {
    const small = { ...plateTimeline("preview-run", 10), pixelWidth: 1320, pixelHeight: 2868 };
    const short = { ...preview, scenes: [{ ...preview.scenes[0]!, toSeconds: 9 }] };
    const scaled = await run({ timelines: [small, plateTimeline("preview-nodo", 10)] });
    expect(scaled.outcome.ok && scaled.outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-PLATE"]);
    expect(scaled.toolbox.renders).toEqual([]);
    const brief = await run({ story: short });
    expect(brief.outcome.ok && brief.outcome.value.findings.map((entry) => entry.rule)).toContain("MEDIA-DURATION");
  });

  it("reports a missing plate and an encoder failure as values", async () => {
    const missing = await run({ timelines: [plateTimeline("preview-run", 10)] });
    expect(missing.outcome).toEqual({ ok: false, error: "plates/preview-nodo/iphone-preview/dark/es holds no readable timeline.json" });
    const broken = await run({ script: { encode: { ok: false, error: "encoder exploded" } } });
    expect(broken.outcome).toEqual({ ok: false, error: "encoder exploded" });
    const unassembled = await run({ script: { assemble: { ok: false, error: "no frames" } } });
    expect(unassembled.outcome).toEqual({ ok: false, error: "no frames" });
  });

});

describe("producePreview disclosure and delivery", () => {
  it("refuses to show Nodo without saying it needs sign-in and a subscription", async () => {
    const silent = { ...preview, scenes: preview.scenes.map((scene) => ({ ...scene, captions: scene.captions.filter((caption) => caption.role !== "disclosure") })) };
    const unframed = await run({ story: silent, frame: { brand: null, disclosure: story.disclosure } });
    expect(unframed.outcome.ok && unframed.outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-DISCLOSURE"]);
    const carded = await run({ story: silent });
    expect(carded.outcome.ok && carded.outcome.value.findings).toEqual([]);
  });

  it("audits the delivered file and rejects a low bitrate", async () => {
    const { outcome } = await run({ script: { probe: { delivery: { ...goodProbe({ width: 886, height: 1920 }).delivery, videoBitrateBps: 714_193 } } } });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-BITRATE"]);
  });
});
