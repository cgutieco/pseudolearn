import { describe, expect, it } from "vitest";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceTrailer } from "../../src/pipeline/produce_trailer.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox, type FakeToolbox } from "../support/fake_toolbox.ts";
import { brandFont } from "../support/lens.ts";
import { pngBytes } from "../support/png.ts";
import { trailerProbe } from "../support/probe.ts";
import { shippedThermostat } from "../support/thermostat.ts";

const catalog = realCatalog();
const fonts = { sans: brandFont("IBMPlexSans-Bold.ttf"), mono: brandFont("IBMPlexMono-Medium.ttf") };
const PLATE = "plates/preview-run/mac-preview/light/es";
const thirty = { ok: true as const, value: { framePattern: "f/frame_%06d.png", startNumber: 1, frameCount: 900 } };

function record(toolbox: FakeToolbox, size = { width: 1920, height: 1080 }, frames = 264): void {
  const timeline = { scene: "preview-run", language: "es", fps: 30, pixelWidth: size.width, pixelHeight: size.height,
    frames: Array.from({ length: frames }, (_unused, index) => ({ index, file: "frame_000001.png", focus: [] })), events: [] };
  toolbox.written.set(`${PLATE}/timeline.json`, new TextEncoder().encode(JSON.stringify(timeline)));
}

async function run(prepare: (toolbox: FakeToolbox) => void = record, slotId = "microsoft.trailer", story = shippedThermostat()) {
  const toolbox = fakeToolbox({ frames: thirty, still: pngBytes({ width: 1920, height: 1080, colorType: 2 }) }, trailerProbe({ durationSeconds: 30 }));
  prepare(toolbox);
  const job = planJobs({ catalog, slotIds: [slotId], languages: ["es"] }).jobs[0]!;
  return { toolbox, outcome: await produceTrailer({ toolbox, catalog, job, story, fonts, platesRoot: "plates", outputRoot: "out" }) };
}

const DIRECTORY = "out/microsoft-store/microsoft.trailer/es";

describe("produceTrailer", () => {
  it("renders the trailer with its interface tail, takes the thumbnail and writes the listing data", async () => {
    const { toolbox, outcome } = await run();
    expect(outcome.ok && isAccepted(outcome.value.video)).toBe(true);
    expect(outcome.ok && outcome.value.thumbnail).toEqual({ file: `${DIRECTORY}/thermostat-es-thumbnail.png`, findings: [] });
    expect(toolbox.written.has(`${DIRECTORY}/project/interface.mp4`)).toBe(true);
    expect(JSON.parse(String(toolbox.written.get(`${DIRECTORY}/trailer.json`)))).toMatchObject({ locales: ["es-ES"], title: "PseudoLearn: mira tu programa ejecutarse paso a paso" });
  });
});

describe("produceTrailer rejections", () => {
  it("refuses to render without the interface plate, with a plate of another size or one too short", async () => {
    for (const prepare of [() => undefined, (toolbox: FakeToolbox) => record(toolbox, { width: 1280, height: 720 }), (toolbox: FakeToolbox) => record(toolbox, undefined, 30)]) {
      const { toolbox, outcome } = await run(prepare);
      expect(outcome.ok && outcome.value.video.findings.map((entry) => entry.rule)).toEqual(["MEDIA-PLATE"]);
      expect(toolbox.renders).toEqual([]);
    }
  });

  it("refuses a title over 255 characters and a slot that is not a trailer", async () => {
    const story = { ...shippedThermostat(), title: { es: "t".repeat(256), en: "t" } };
    expect((await run(record, "microsoft.trailer", story)).outcome.ok && (await run(record, "microsoft.trailer", story)).outcome).toMatchObject({ value: { video: { findings: [{ rule: "TEXT-LENGTH" }] } } });
    expect((await run(record, "microsoft.hero-art")).outcome).toEqual({ ok: false, error: "microsoft.hero-art is not a trailer slot" });
  });
});
