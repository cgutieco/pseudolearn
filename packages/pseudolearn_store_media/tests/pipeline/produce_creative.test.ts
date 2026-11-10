import { describe, expect, it } from "vitest";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceCreative } from "../../src/pipeline/produce_creative.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { brandFont, shippedLensStory, uniformFont } from "../support/lens.ts";
import { goodProbe } from "../support/probe.ts";
import { pngBytes } from "../support/png.ts";

const catalog = realCatalog();
const story = shippedLensStory();
const fonts = { sans: brandFont("IBMPlexSans-Bold.ttf"), mono: brandFont("IBMPlexMono-Medium.ttf") };

function jobFor(id: string) {
  return planJobs({ catalog, slotIds: [id], languages: ["en"] }).jobs[0]!;
}

describe("produceCreative", () => {
  it("renders the header loop with its fonts, soundtrack and review board", async () => {
    const toolbox = fakeToolbox({ frames: { ok: true, value: { framePattern: "f/frame_%06d.png", startNumber: 1, frameCount: 600 } } },
      goodProbe({ width: 3840, height: 1646 }, { durationSeconds: 20 }));
    const outcome = await produceCreative({ toolbox, catalog, job: jobFor("apple.header.video"), story, fonts, outputRoot: "out" });
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    const directory = "out/app-store/apple.header.video/en";
    expect(toolbox.written.get(`${directory}/project/headline.ttf`)).toBe(fonts.sans.bytes);
    expect(toolbox.encodes[0]?.audioPath).toBe(`${directory}/soundtrack.wav`);
    expect(toolbox.written.has(`${directory}/safe-area-review.png`)).toBe(true);
  });

  it("renders the universal image as one opaque still", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 5244, height: 2950, colorType: 2 }) }, goodProbe({ width: 5244, height: 2950 }));
    const outcome = await produceCreative({ toolbox, catalog, job: jobFor("apple.universal.image"), story, fonts, outputRoot: "out" });
    expect(outcome.ok && outcome.value.file).toBe("out/app-store/apple.universal.image/en/lens-apple-universal-image-en.png");
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    expect(toolbox.encodes).toEqual([]);
  });

  it("rejects a universal image that comes out transparent", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 5244, height: 2950, colorType: 6 }) }, goodProbe({ width: 5244, height: 2950 }));
    const outcome = await produceCreative({ toolbox, catalog, job: jobFor("apple.universal.image"), story, fonts, outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-ALPHA"]);
  });

  it("refuses to render when the labels would not fit their nodes", async () => {
    const toolbox = fakeToolbox({}, goodProbe({ width: 3840, height: 1646 }));
    const crowded = { sans: uniformFont(2), mono: uniformFont(0.6) };
    const outcome = await produceCreative({ toolbox, catalog, job: jobFor("apple.header.video"), story, fonts: crowded, outputRoot: "out" });
    expect(outcome.ok && [...new Set(outcome.value.findings.map((entry) => entry.rule))]).toEqual(["TEXT-FIT"]);
    expect(outcome.ok && outcome.value.file).toBeNull();
    expect(toolbox.renders).toEqual([]);
  });
});

describe("produceCreative content rules", () => {
  it("refuses a lens with code and labels as Microsoft hero art before rendering", async () => {
    const toolbox = fakeToolbox({}, goodProbe({ width: 3840, height: 2160 }));
    const outcome = await produceCreative({ toolbox, catalog, job: jobFor("microsoft.hero-art"), story, fonts, outputRoot: "out" });
    const content = outcome.ok ? outcome.value.findings.filter((entry) => entry.rule === "MEDIA-CONTENT").map((entry) => entry.message) : [];
    expect(content).toContain("lens declares no content kind");
    expect(content.some((message) => message.endsWith("which no-text forbids"))).toBe(true);
    expect(outcome.ok && outcome.value.file).toBeNull();
    expect(toolbox.renders).toEqual([]);
  });
});
