import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { loadScreenshotStory } from "../../src/pipeline/story_source.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { storyDocument } from "../support/story.ts";

function request() {
  return { toolbox: fakeToolbox({}, {} as VideoProbe) };
}

describe("loadScreenshotStory", () => {
  it("parses a story file", async () => {
    const { toolbox } = request();
    await toolbox.files.writeBytes("story.json", new TextEncoder().encode(JSON.stringify(storyDocument())));
    const parsed = await loadScreenshotStory(toolbox.files, "story.json");
    expect(parsed.ok && parsed.value.id).toBe("test-story");
  });

  it("reports a missing file and invalid JSON", async () => {
    const { toolbox } = request();
    await toolbox.files.writeBytes("broken.json", new TextEncoder().encode("{"));
    const missing = await loadScreenshotStory(toolbox.files, "none.json");
    const broken = await loadScreenshotStory(toolbox.files, "broken.json");
    expect(!missing.ok && missing.errors[0]?.message).toBe("the story file does not exist");
    expect(!broken.ok && broken.errors[0]?.message.startsWith("the story is not valid JSON")).toBe(true);
  });
});
