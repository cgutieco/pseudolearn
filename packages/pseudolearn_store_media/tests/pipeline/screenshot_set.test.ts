import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { produceScreenshotSet, type ScreenshotSetRequest } from "../../src/pipeline/screenshot_set.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { TEST_STORY } from "../support/story.ts";

const fontBytes = (name: string) => new Uint8Array(readFileSync(fileURLToPath(new URL(`../../../pseudolearn_brand/assets/fonts/${name}`, import.meta.url))));

function request(slotIds: readonly string[], overrides: Partial<ScreenshotSetRequest> = {}): ScreenshotSetRequest {
  const catalog = realCatalog();
  const toolbox = fakeToolbox({}, {} as VideoProbe);
  toolbox.written.set("sans.ttf", fontBytes("IBMPlexSans-Bold.ttf"));
  toolbox.written.set("mono.ttf", fontBytes("IBMPlexMono-Medium.ttf"));
  return { toolbox, catalog, jobs: planJobs({ catalog, slotIds, languages: ["es", "en"] }).jobs, story: TEST_STORY,
    fontPaths: { sans: "sans.ttf", mono: "mono.ttf" }, platesRoot: "plates", outputRoot: "out", guides: false, ...overrides };
}

describe("produceScreenshotSet", () => {
  it("produces one manifest per chapter, slot and language", async () => {
    const outcome = await produceScreenshotSet(request(["apple.iphone.screenshot", "apple.ipad.screenshot"]));
    expect(outcome.ok && outcome.value.map((result) => `${result.job.slot.id}/${result.job.language}/${result.chapter}`)).toEqual([
      "apple.iphone.screenshot/es/language", "apple.iphone.screenshot/es/nodo",
      "apple.iphone.screenshot/en/language", "apple.iphone.screenshot/en/nodo",
      "apple.ipad.screenshot/es/language", "apple.ipad.screenshot/es/nodo",
      "apple.ipad.screenshot/en/language", "apple.ipad.screenshot/en/nodo",
    ]);
  });
});

describe("produceScreenshotSet rejections", () => {
  it("refuses video slots and an empty plan", async () => {
    expect(await produceScreenshotSet(request(["apple.mac.app-preview"])))
      .toEqual({ ok: false, error: "screenshots need screenshot slots; not one: apple.mac.app-preview" });
    expect(await produceScreenshotSet(request([], { jobs: [] }))).toEqual({ ok: false, error: "screenshots need screenshot slots" });
  });

  it("refuses more chapters than the slot accepts", async () => {
    const chapters = Array.from({ length: 11 }, (_, index) => ({ ...TEST_STORY.chapters[1], id: `c${index}` })) as typeof TEST_STORY.chapters;
    const outcome = await produceScreenshotSet(request(["apple.mac.screenshot"], { story: { ...TEST_STORY, chapters } }));
    expect(outcome).toEqual({ ok: false, error: "11 chapters exceed the 10 images apple.mac.screenshot allows" });
  });

  it("refuses a missing or unreadable font", async () => {
    expect(await produceScreenshotSet(request(["apple.mac.screenshot"], { fontPaths: { sans: "nowhere.ttf", mono: "mono.ttf" } })))
      .toEqual({ ok: false, error: "missing font nowhere.ttf" });
    const broken = request(["apple.mac.screenshot"]);
    await broken.toolbox.files.writeBytes("mono.ttf", new Uint8Array(3));
    expect(await produceScreenshotSet(broken)).toEqual({ ok: false, error: "mono.ttf: the font file is truncated" });
  });
});
