import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceHero } from "../../src/pipeline/produce_hero.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { brandFont, shippedLensStory } from "../support/lens.ts";
import { pngBytes } from "../support/png.ts";

const catalog = realCatalog();
const mono = brandFont("IBMPlexMono-Medium.ttf").advances;

function jobFor(id: string) {
  return planJobs({ catalog, slotIds: [id], languages: ["en"] }).jobs[0]!;
}

describe("produceHero", () => {
  it("renders the hero art as one opaque still", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 3840, height: 2160, colorType: 2 }) }, {} as VideoProbe);
    const outcome = await produceHero({ toolbox, catalog, job: jobFor("microsoft.hero-art"), story: shippedLensStory(), mono, outputRoot: "out" });
    expect(outcome.ok && outcome.value.file).toBe("out/microsoft-store/microsoft.hero-art/en/mute-lens-hero-art-en.png");
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
  });
});

describe("produceHero for the Google Play feature graphic", () => {
  it("renders the feature graphic as an opaque still with no text inside its centred safe area", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 1024, height: 500, colorType: 2 }) }, {} as VideoProbe);
    const outcome = await produceHero({ toolbox, catalog, job: jobFor("google-play.feature-graphic"), story: shippedLensStory(), mono, outputRoot: "out" });
    expect(outcome.ok && outcome.value.file).toBe("out/google-play/google-play.feature-graphic/en/mute-lens-feature-graphic-en.png");
    expect(outcome.ok && outcome.value.findings).toEqual([]);
  });
});

describe("produceHero rejections", () => {
  it("rejects a hero that comes out transparent", async () => {
    const toolbox = fakeToolbox({ flattened: pngBytes({ width: 3840, height: 2160, colorType: 6 }) }, {} as VideoProbe);
    const outcome = await produceHero({ toolbox, catalog, job: jobFor("microsoft.hero-art"), story: shippedLensStory(), mono, outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-ALPHA"]);
  });

  it("refuses a slot that is not hero, poster or box art or a feature graphic", async () => {
    const toolbox = fakeToolbox({}, {} as VideoProbe);
    expect(await produceHero({ toolbox, catalog, job: jobFor("microsoft.trailer-thumbnail"), story: shippedLensStory(), mono, outputRoot: "out" }))
      .toEqual({ ok: false, error: "microsoft.trailer-thumbnail is not hero, poster or box art or a feature graphic" });
  });
});
