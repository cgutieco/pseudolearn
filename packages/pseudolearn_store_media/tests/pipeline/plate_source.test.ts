import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { readPlate } from "../../src/pipeline/plate_source.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { MAC_NODO, recordMacNodo } from "../support/plates.ts";
import { chapterOf, TEST_STORY } from "../support/story.ts";

const place = { chapter: chapterOf(TEST_STORY, "nodo"), device: "mac", language: "es" as const };

describe("readPlate", () => {
  it("reads the frame and the focus rectangles of the recorded plate", async () => {
    const toolbox = fakeToolbox({}, {} as VideoProbe);
    recordMacNodo(toolbox);
    const plate = await readPlate(toolbox.files, "plates", place);
    expect(plate.image).not.toBeNull();
    expect(plate.focus?.get("verified-code")).toEqual({ x: 2000, y: 600, width: 700, height: 800 });
  });
});

describe("readPlate rejections", () => {
  it("reports a missing plate as empty", async () => {
    const plate = await readPlate(fakeToolbox({}, {} as VideoProbe).files, "plates", place);
    expect(plate).toEqual({ image: null, focus: null });
  });

  it("reports an unreadable or invalid timeline as no focus", async () => {
    const toolbox = fakeToolbox({}, {} as VideoProbe);
    recordMacNodo(toolbox);
    toolbox.written.set(`${MAC_NODO}/timeline.json`, new TextEncoder().encode("{"));
    expect((await readPlate(toolbox.files, "plates", place)).focus).toBeNull();
    toolbox.written.set(`${MAC_NODO}/timeline.json`, new TextEncoder().encode("{\"scene\": 1}"));
    expect((await readPlate(toolbox.files, "plates", place)).focus).toBeNull();
  });
});
