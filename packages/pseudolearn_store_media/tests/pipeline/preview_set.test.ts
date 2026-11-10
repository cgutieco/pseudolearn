import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { producePreviewSet } from "../../src/pipeline/preview_set.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { previewStory } from "../support/preview.ts";
import { goodProbe } from "../support/probe.ts";

const catalog = realCatalog();
const FONT = new URL("../../../pseudolearn_brand/assets/fonts/IBMPlexSans-Bold.ttf", import.meta.url).pathname;

function request(slotIds: readonly string[], fontPath = FONT) {
  const toolbox = fakeToolbox({}, goodProbe({ width: 886, height: 1920 }));
  return { toolbox, catalog, jobs: planJobs({ catalog, slotIds, languages: ["es"] }).jobs, story: previewStory(), fontPath, platesRoot: "p", outputRoot: "o" };
}

describe("producePreviewSet", () => {
  it("refuses jobs that are not app previews and an empty job list", async () => {
    expect(await producePreviewSet(request(["apple.iphone.screenshot"])))
      .toEqual({ ok: false, error: "previews need app-preview slots; not one: apple.iphone.screenshot" });
    expect(await producePreviewSet(request(["nothing"]))).toEqual({ ok: false, error: "previews need app-preview slots" });
  });

  it("produces every preview of the story for every job and keeps each outcome", async () => {
    const built = request(["apple.iphone.app-preview", "apple.mac.app-preview"]);
    built.toolbox.written.set(FONT, new Uint8Array(readFileSync(FONT)));
    const outcome = await producePreviewSet(built);
    expect(outcome.ok && outcome.value.map((result) => [result.job.slot.id, result.preview, result.outcome.ok])).toEqual([
      ["apple.iphone.app-preview", "overview", false],
      ["apple.mac.app-preview", "overview", false],
    ]);
  });

  it("refuses a font it cannot read", async () => {
    expect(await producePreviewSet(request(["apple.iphone.app-preview"], "missing.ttf")))
      .toEqual({ ok: false, error: "cannot read the font missing.ttf" });
  });
});
