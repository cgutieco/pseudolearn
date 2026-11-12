import { describe, expect, it } from "vitest";
import { CALIBRATION_VOICE } from "../../src/audio/score.ts";
import type { VideoProbe } from "../../src/audit/video_audit.ts";
import { buildCalibration } from "../../src/compose/calibration.ts";
import { isAccepted } from "../../src/pipeline/manifest.ts";
import { produceVideo } from "../../src/pipeline/produce_video.ts";
import { planJobs } from "../../src/pipeline/render_plan.ts";
import { calibrationStoryboard } from "../../src/story/calibration_storyboard.ts";
import { realCatalog } from "../support/catalog.ts";
import { trailerProbe } from "../support/probe.ts";
import { fakeToolbox, type FakeScript } from "../support/fake_toolbox.ts";

const catalog = realCatalog();

const baseProbe: VideoProbe = trailerProbe();
const HEADER_AUDIO = { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 256_000 };

function run(slotId: string, script: FakeScript = {}, probe: VideoProbe = baseProbe) {
  const [job] = planJobs({ catalog, slotIds: [slotId], languages: ["es"] }).jobs;
  if (!job) {
    throw new Error("job expected");
  }
  const storyboard = calibrationStoryboard(job.slot);
  const composition = buildCalibration({ slot: job.slot, durationSeconds: storyboard.durationSeconds, beats: storyboard.beats, guides: false });
  const toolbox = fakeToolbox(script, probe);
  const result = produceVideo({ toolbox, catalog, job, composition, storyboard, voice: CALIBRATION_VOICE, outputRoot: "out" });
  return { toolbox, result, composition };
}

describe("produceVideo", () => {
  it("renders, scores, encodes, audits and writes an accepted manifest", async () => {
    const { toolbox, result, composition } = run("microsoft.trailer");
    const outcome = await result;
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    expect(toolbox.written.get("out/microsoft-store/microsoft.trailer/es/project/index.html")).toBe(composition.html);
    expect(toolbox.written.has("out/microsoft-store/microsoft.trailer/es/project/gsap.min.js")).toBe(true);
    expect(toolbox.encodes[0]?.audioPath).toBe("out/microsoft-store/microsoft.trailer/es/soundtrack.wav");
    expect(toolbox.encodes[0]?.startNumber).toBe(1);
    expect(toolbox.written.has(`out/microsoft-store/microsoft.trailer/es/${composition.id}.audit.json`)).toBe(true);
  });

  it("encodes the search video without a soundtrack", async () => {
    const probe = { ...baseProbe, width: 3840, height: 2560, audio: null, delivery: { ...baseProbe.delivery, videoBitrateBps: 20_000_000 } };
    const { toolbox, result } = run("apple.search.video", {}, probe);
    const outcome = await result;
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    expect(toolbox.encodes[0]?.audioPath).toBeNull();
  });


  it("checks every frame of the header against the device crops and draws the review board", async () => {
    const probe = { ...baseProbe, width: 3840, height: 1646, durationSeconds: 10, audio: HEADER_AUDIO };
    const { toolbox, result } = run("apple.header.video", { frames: { ok: true, value: { framePattern: "f/frame_%06d.png", startNumber: 1, frameCount: 300 } } }, probe);
    const outcome = await result;
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
    expect(toolbox.written.has("out/app-store/apple.header.video/es/safe-area-review.png")).toBe(true);
  });
});

describe("produceVideo safe-area coverage", () => {
  it("refuses to render a header whose layout skips frames", async () => {
    const [job] = planJobs({ catalog, slotIds: ["apple.header.video"], languages: ["es"] }).jobs;
    const storyboard = calibrationStoryboard(job!.slot);
    const full = buildCalibration({ slot: job!.slot, durationSeconds: storyboard.durationSeconds, beats: storyboard.beats, guides: false });
    const composition = { ...full, layout: full.layout.slice(0, 1) };
    const toolbox = fakeToolbox({}, baseProbe);
    const outcome = await produceVideo({ toolbox, catalog, job: job!, composition, storyboard, voice: CALIBRATION_VOICE, outputRoot: "out" });
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-SAFE-AREA"]);
    expect(toolbox.renders).toEqual([]);
  });
});

describe("produceVideo rejections", () => {
  it("rejects a looping header when the encoded loop jumps", async () => {
    const probe = { ...baseProbe, width: 3840, height: 1646, durationSeconds: 10, audio: HEADER_AUDIO };
    const outcome = await run("apple.header.video", { lastFrame: new Uint8Array(600 * 400 * 3).fill(200),
      frames: { ok: true, value: { framePattern: "f/frame_%06d.png", startNumber: 1, frameCount: 300 } } }, probe).result;
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-LOOP"]);
  });

  it("does not ask a slot without seamless-loop to loop", async () => {
    const outcome = await run("microsoft.trailer", { lastFrame: new Uint8Array(600 * 400 * 3).fill(200) }).result;
    expect(outcome.ok && isAccepted(outcome.value)).toBe(true);
  });

  it("rejects the piece when the soundtrack misses the loudness target", async () => {
    const quiet = [{ integratedLufs: -30, truePeakDb: -2 }, { integratedLufs: -19, truePeakDb: -1.2 }];
    const outcome = await run("microsoft.trailer", { loudness: quiet }).result;
    expect(outcome.ok && outcome.value.findings.map((entry) => entry.rule)).toEqual(["MEDIA-LOUDNESS"]);
  });

  it("returns the renderer failure as a value and encodes nothing", async () => {
    const { toolbox, result } = run("microsoft.trailer", { frames: { ok: false, error: "chrome crashed" } });
    expect(await result).toEqual({ ok: false, error: "chrome crashed" });
    expect(toolbox.encodes).toEqual([]);
  });

  it("returns the encoder failure as a value", async () => {
    expect(await run("microsoft.trailer", { encode: { ok: false, error: "ffmpeg exited with 1" } }).result)
      .toEqual({ ok: false, error: "ffmpeg exited with 1" });
  });

  it("refuses a still slot", async () => {
    const [job] = planJobs({ catalog, slotIds: ["apple.mac.screenshot"], languages: ["es"] }).jobs;
    const composition = buildCalibration({ slot: job!.slot, durationSeconds: 1, beats: [], guides: false });
    const outcome = await produceVideo({ toolbox: fakeToolbox({}, baseProbe), catalog, job: job!, composition,
      storyboard: { id: "still", durationSeconds: 1, beats: [] }, voice: CALIBRATION_VOICE, outputRoot: "out" });
    expect(outcome).toEqual({ ok: false, error: "apple.mac.screenshot is not a video slot" });
  });
});
