import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { assembleTailPlate } from "../../src/pipeline/trailer_plate.ts";
import { slot } from "../support/catalog.ts";
import { fakeToolbox, type FakeScript } from "../support/fake_toolbox.ts";
import { shippedThermostat } from "../support/thermostat.ts";

const tail = shippedThermostat().interface;

function setUp(script: FakeScript, timeline: string | null) {
  const toolbox = fakeToolbox(script, {} as VideoProbe);
  if (timeline !== null) {
    toolbox.written.set("plates/preview-run/mac-preview/light/en/timeline.json", new TextEncoder().encode(timeline));
  }
  return assembleTailPlate(toolbox, { root: "plates", tail, language: "en", slot: slot("microsoft.trailer"), output: "out/source.mp4", name: "t" });
}

const valid = JSON.stringify({ scene: "preview-run", language: "en", fps: 30, pixelWidth: 1920, pixelHeight: 1080,
  frames: Array.from({ length: 240 }, (_unused, index) => ({ index, file: "frame_000001.png", focus: [] })), events: [] });

describe("assembleTailPlate", () => {
  it("assembles the recorded frames into the interface clip", async () => {
    const outcome = await setUp({}, valid);
    expect(outcome.ok && outcome.value.asset?.name).toBe("interface.mp4");
    expect(outcome.ok && outcome.value.findings).toEqual([]);
  });

  it("reports an unreadable timeline as a finding and an assembly failure as a value", async () => {
    const broken = await setUp({}, "{");
    expect(broken.ok && broken.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-PLATE"]);
    expect(await setUp({ assemble: { ok: false, error: "ffmpeg failed" } }, valid)).toEqual({ ok: false, error: "ffmpeg failed" });
  });
});
