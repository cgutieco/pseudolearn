import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { CALIBRATION_VOICE } from "../../src/audio/score.ts";
import { synthesize } from "../../src/audio/synthesizer.ts";
import { encodeWav } from "../../src/audio/wav_encoder.ts";
import { auditDelivery } from "../../src/audit/delivery_audit.ts";
import { ffmpegToolkit } from "../../src/render/ffmpeg_toolkit.ts";
import { framesIn } from "../../src/render/hyperframes_renderer.ts";
import { runProcess } from "../../src/render/process_runner.ts";
import { slot } from "../support/catalog.ts";

const toolkit = ffmpegToolkit();
const profile = slot("apple.iphone.app-preview").video!.codecProfile;
let directory = "";

beforeAll(async () => {
  directory = mkdtempSync(join(tmpdir(), "store-media-"));
  const frames = join(directory, "frames");
  await runProcess("mkdir", [frames]);
  const made = await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "color=c=0x195C5F:s=64x128:r=30:d=1",
    "-start_number", "1", join(frames, "frame_%06d.png")]);
  expect(made.code).toBe(0);
  const signal = synthesize({ sampleRate: 48000, durationSeconds: 1, voice: CALIBRATION_VOICE, beats: [{ atSeconds: 0.2, kind: "accent", degree: 0, weight: 1 }] });
  writeFileSync(join(directory, "track.wav"), encodeWav(signal));
});

afterAll(() => {
  rmSync(directory, { recursive: true, force: true });
});

describe("ffmpeg toolkit against the real binaries", () => {
  it("finds the contiguous frames the renderer leaves", async () => {
    const frames = await framesIn(join(directory, "frames"));
    expect(frames).toEqual({ ok: true, value: { framePattern: join(directory, "frames", "frame_%06d.png"), startNumber: 1, frameCount: 30 } });
  });

  it("encodes, probes, samples and measures a short piece", async () => {
    const output = join(directory, "piece.mp4");
    const encoded = await toolkit.encode({ framePattern: join(directory, "frames", "frame_%06d.png"), startNumber: 1, fps: 30,
      audioPath: join(directory, "track.wav"), profile, outputPath: output });
    expect(encoded).toEqual({ ok: true, value: output });
    const probe = await toolkit.probe(output);
    expect(probe.ok && [probe.value.width, probe.value.height, probe.value.codec, probe.value.colorPrimaries]).toEqual([64, 128, "h264", "bt709"]);
    expect(probe.ok && probe.value.audio?.sampleRate).toBe(48000);
    const first = await toolkit.sampleFrame(output, 0);
    expect(first.ok && first.value.length).toBe(600 * 1200 * 3);
    const loudness = await toolkit.measureLoudness(join(directory, "track.wav"));
    expect(loudness.ok && Number.isFinite(loudness.value.integratedLufs)).toBe(true);
  });

});

describe("ffmpeg toolkit delivery against the real binaries", () => {
  it("delivers a preview between 10 and 12 Mbps even when the picture never changes", async () => {
    const still = join(directory, "still");
    await runProcess("mkdir", [still]);
    await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "color=c=0x195C5F:s=64x128:r=30:d=5",
      "-start_number", "1", join(still, "frame_%06d.png")]);
    const output = join(directory, "constant.mp4");
    writeFileSync(join(still, "track.wav"), encodeWav(synthesize({ sampleRate: 48000, durationSeconds: 5, voice: CALIBRATION_VOICE, beats: [] })));
    await toolkit.encode({ framePattern: join(still, "frame_%06d.png"), startNumber: 1, fps: 30,
      audioPath: join(still, "track.wav"), profile, outputPath: output });
    const probe = await toolkit.probe(output);
    expect(probe.ok && probe.value.delivery.videoBitrateBps).toBeGreaterThanOrEqual(10_000_000);
    expect(probe.ok && probe.value.delivery.videoBitrateBps).toBeLessThanOrEqual(12_000_000);
    expect(probe.ok && [probe.value.delivery.level, probe.value.delivery.fieldOrder, probe.value.delivery.extension]).toEqual([40, "progressive", "mp4"]);
    expect(probe.ok && probe.value.delivery.structure.boxOrder.indexOf("moov")).toBeLessThan(probe.ok ? probe.value.delivery.structure.boxOrder.indexOf("mdat") : 0);
  });

});

describe("ffmpeg toolkit Microsoft delivery against the real binaries", () => {
  it("delivers a Microsoft trailer with a closed GOP, two B frames, fast start and no edit lists", async () => {
    const moving = join(directory, "moving");
    await runProcess("mkdir", [moving]);
    await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "testsrc2=s=160x90:r=30:d=3",
      "-start_number", "1", join(moving, "frame_%06d.png")]);
    await runProcess("ffmpeg", ["-hide_banner", "-loglevel", "error", "-f", "lavfi", "-i", "anoisesrc=d=3:a=0.3:r=48000", "-ac", "2",
      join(moving, "track.wav")]);
    const trailer = slot("microsoft.trailer").video!.codecProfile;
    const output = join(directory, "trailer.mp4");
    await toolkit.encode({ framePattern: join(moving, "frame_%06d.png"), startNumber: 1, fps: 30, audioPath: join(moving, "track.wav"), profile: trailer, outputPath: output });
    const probe = await toolkit.probe(output);
    expect(probe.ok && probe.value.delivery.structure.keyFrames).toEqual([0, 15, 30, 45, 60, 75]);
    expect(probe.ok && probe.value.delivery.structure.editLists).toBe(0);
    const findings = probe.ok ? auditDelivery({ profile: trailer, target: "trailer.mp4", probe: probe.value }) : [];
    expect(findings).toEqual([]);
  });

});

describe("ffmpeg toolkit stills against the real binaries", () => {
  it("extracts a poster frame as a PNG", async () => {
    const output = join(directory, "piece.mp4");
    const still = await toolkit.extractStill({ videoPath: output, frameIndex: 5, longSide: 600, outputPath: join(directory, "poster.png") });
    expect(still).toEqual({ ok: true, value: join(directory, "poster.png") });
    expect((await toolkit.extractStill({ videoPath: join(directory, "missing.mp4"), frameIndex: 0, longSide: null, outputPath: join(directory, "x.png") })).ok).toBe(false);
  });

});

describe("ffmpeg toolkit failures against the real binaries", () => {
  it("returns failures as values", async () => {
    expect((await toolkit.probe(join(directory, "missing.mp4"))).ok).toBe(false);
    expect((await toolkit.sampleFrame(join(directory, "missing.mp4"), 0)).ok).toBe(false);
    expect((await framesIn(directory)).ok).toBe(false);
  });

  it("rejects a gap in the frame numbering", async () => {
    const gapped = join(directory, "gapped");
    await runProcess("mkdir", [gapped]);
    writeFileSync(join(gapped, "frame_000001.png"), "");
    writeFileSync(join(gapped, "frame_000003.png"), "");
    expect(await framesIn(gapped)).toEqual({ ok: false, error: `frames in ${gapped} are not contiguous` });
  });
});
