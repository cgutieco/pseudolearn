import { describe, expect, it } from "vitest";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { produceCalibration } from "../../src/pipeline/produce_calibration.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { realCatalog } from "../support/catalog.ts";
import { fakeToolbox } from "../support/fake_toolbox.ts";

const catalog = realCatalog();
const trailerProbe: VideoProbe = {
  width: 1920, height: 1080, framesPerSecond: 30, durationSeconds: 15, codec: "h264", profile: "High",
  pixelFormat: "yuv420p", colorPrimaries: "bt709", rotation: 0, sizeBytes: 1_000_000,
  audio: { codec: "aac", sampleRate: 48000, channels: 2 },
};

describe("produceCalibration", () => {
  it("produces the Microsoft trailer calibration with the trailer codec profile", async () => {
    const [job] = planJobs({ catalog, slotIds: ["microsoft.trailer"], languages: ["es"] }).jobs;
    const toolbox = fakeToolbox({}, trailerProbe);
    const outcome = await produceCalibration({ toolbox, catalog, job: job!, guides: true, outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings).toEqual([]);
    expect(toolbox.encodes[0]?.profile.id).toBe("microsoft-trailer");
    expect(String(toolbox.written.get("out/microsoft-store/microsoft.trailer/es/project/index.html"))).toContain('id="guide"');
  });

  it("reports a trailer that comes back with the wrong size", async () => {
    const [job] = planJobs({ catalog, slotIds: ["microsoft.trailer"], languages: ["es"] }).jobs;
    const toolbox = fakeToolbox({ probe: { width: 1280, height: 720 } }, trailerProbe);
    const outcome = await produceCalibration({ toolbox, catalog, job: job!, guides: false, outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-DIMENSIONS"]);
  });
});
