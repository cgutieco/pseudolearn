import { describe, expect, it } from "vitest";
import { loadPreviewStory, readPreviewPlates } from "../../src/pipeline/preview_source.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { plateTimeline, previewDocument, previewStory } from "../support/preview.ts";
import { goodProbe } from "../support/probe.ts";

const encode = (value: unknown) => new TextEncoder().encode(typeof value === "string" ? value : JSON.stringify(value));
const preview = previewStory().previews[0]!;

function toolbox() {
  return fakeToolbox({}, goodProbe({ width: 886, height: 1920 }));
}

describe("loadPreviewStory", () => {
  it("parses a story file", async () => {
    const box = toolbox();
    box.written.set("story.json", encode(previewDocument()));
    const loaded = await loadPreviewStory(box.files, "story.json");
    expect(loaded.ok && loaded.value.previews.map((entry) => entry.id)).toEqual(["overview"]);
  });

  it("reports a missing file and invalid JSON", async () => {
    const box = toolbox();
    box.written.set("broken.json", encode("{"));
    expect(await loadPreviewStory(box.files, "nowhere.json")).toEqual({ ok: false, errors: [{ path: "nowhere.json", message: "the story file does not exist" }] });
    const broken = await loadPreviewStory(box.files, "broken.json");
    expect(broken.ok ? "" : broken.errors[0]?.message).toContain("the story is not valid JSON");
  });
});

describe("readPreviewPlates", () => {
  it("reads one timeline per scene from plate, device, theme and language", async () => {
    const box = toolbox();
    box.written.set("p/preview-run/iphone-preview/light/en/timeline.json", encode(plateTimeline("preview-run", 2)));
    box.written.set("p/preview-nodo/iphone-preview/dark/en/timeline.json", encode(plateTimeline("preview-nodo", 3)));
    const plates = await readPreviewPlates(box.files, "p", { preview, device: "iphone-preview", language: "en" });
    expect(plates.problems).toEqual([]);
    expect(plates.timelines.map((timeline) => timeline.frames.length)).toEqual([60, 90]);
    expect(plates.directories).toEqual(["p/preview-run/iphone-preview/light/en", "p/preview-nodo/iphone-preview/dark/en"]);
  });

  it("stops at the first plate that is missing or does not follow the contract", async () => {
    const box = toolbox();
    box.written.set("p/preview-run/iphone-preview/light/es/timeline.json", encode({ scene: "x" }));
    const plates = await readPreviewPlates(box.files, "p", { preview, device: "iphone-preview", language: "es" });
    expect(plates.problems).toEqual(["p/preview-run/iphone-preview/light/es holds no readable timeline.json"]);
    box.written.set("p/preview-run/iphone-preview/light/es/timeline.json", encode("not json"));
    expect((await readPreviewPlates(box.files, "p", { preview, device: "iphone-preview", language: "es" })).timelines).toEqual([]);
  });
});
