import { describe, expect, it } from "vitest";
import { needsSafeAreaReview, produceSafeAreaReview, reviewFrameIndices } from "../../src/pipeline/safe_area_review.ts";
import { slot } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";
import { goodProbe } from "../support/probe.ts";

const frames = { framePattern: "out/frames/frame_%06d.png", startNumber: 1, frameCount: 300 };

describe("safe-area review", () => {
  it("is drawn for the Apple header and search videos, not for previews or trailers", () => {
    expect(needsSafeAreaReview(slot("apple.header.video"))).toBe(true);
    expect(needsSafeAreaReview(slot("apple.search.video"))).toBe(true);
    expect(needsSafeAreaReview(slot("apple.iphone.app-preview"))).toBe(false);
    expect(needsSafeAreaReview(slot("microsoft.trailer"))).toBe(false);
  });

  it("samples the start and each quarter of the loop, without repeats", () => {
    expect(reviewFrameIndices(300)).toEqual([0, 75, 150, 225]);
    expect(reviewFrameIndices(2)).toEqual([0, 1]);
    expect(reviewFrameIndices(0)).toEqual([]);
  });

  it("copies the sampled frames, renders the board and flattens it next to the piece", async () => {
    const toolbox = fakeToolbox({}, goodProbe({ width: 3840, height: 1646 }));
    toolbox.written.set("out/frames/frame_000076.png", new Uint8Array([7]));
    const outcome = await produceSafeAreaReview({ toolbox, slot: slot("apple.header.video"), directory: "out", frames, fps: 30 });
    expect(outcome).toEqual({ ok: true, value: "out/safe-area-review.png" });
    expect(toolbox.written.get("out/review/frame-75.png")).toEqual(new Uint8Array([7]));
    expect(String(toolbox.written.get("out/review/index.html"))).toContain("2.50 s · canvas");
    expect(toolbox.renders).toEqual(["out/review"]);
  });

  it("returns the renderer failure as a value", async () => {
    const toolbox = fakeToolbox({ frames: { ok: false, error: "chrome crashed" } }, goodProbe({ width: 3840, height: 1646 }));
    const outcome = await produceSafeAreaReview({ toolbox, slot: slot("apple.header.video"), directory: "out", frames, fps: 30 });
    expect(outcome).toEqual({ ok: false, error: "chrome crashed" });
  });
});
