import { describe, expect, it } from "vitest";
import { parseLoudness, parseProbe } from "../../src/render/ffmpeg_reports.ts";

const probeJson = JSON.stringify({
  streams: [
    { codec_type: "video", codec_name: "h264", profile: "High", pix_fmt: "yuv420p", color_primaries: "bt709", width: 886, height: 1920,
      r_frame_rate: "30000/1001", side_data_list: [{ rotation: -90 }] },
    { codec_type: "audio", codec_name: "aac", sample_rate: "48000", channels: 2 },
  ],
  format: { duration: "15.000000", size: "1813681" },
});

describe("parseProbe", () => {
  it("reads the video and audio streams", () => {
    const outcome = parseProbe(probeJson);
    expect(outcome.ok).toBe(true);
    if (outcome.ok) {
      expect(outcome.value.framesPerSecond).toBeCloseTo(29.97, 2);
      expect(outcome.value.rotation).toBe(90);
      expect(outcome.value.audio).toEqual({ codec: "aac", sampleRate: 48000, channels: 2 });
      expect(outcome.value.sizeBytes).toBe(1813681);
    }
  });

  it("reports a file without video and output that is not JSON", () => {
    expect(parseProbe(JSON.stringify({ streams: [{ codec_type: "audio" }] }))).toEqual({ ok: false, error: "the file has no video stream" });
    expect(parseProbe("Invalid data")).toEqual({ ok: false, error: "ffprobe did not return JSON" });
  });

  it("returns no audio for a silent file", () => {
    const outcome = parseProbe(JSON.stringify({ streams: [{ codec_type: "video", r_frame_rate: "30/1" }], format: {} }));
    expect(outcome.ok && outcome.value.audio).toBeNull();
  });
});

describe("parseLoudness", () => {
  const summary = `[Parsed_ebur128_0 @ 0x1] t: 1 M: -20 S: -20 I: -19.0 LUFS
[Parsed_ebur128_0 @ 0x1] Summary:

  Integrated loudness:
    I:         -16.1 LUFS
    Threshold: -26.1 LUFS

  True peak:
    Peak:       -3.4 dBFS
`;

  it("reads the summary and not the running values", () => {
    expect(parseLoudness(summary)).toEqual({ ok: true, value: { integratedLufs: -16.1, truePeakDb: -3.4 } });
  });

  it("reads minus infinity for silence", () => {
    const silent = "Summary:\n    I:         -inf LUFS\n    Peak:       -inf dBFS\n";
    expect(parseLoudness(silent)).toEqual({ ok: true, value: { integratedLufs: Number.NEGATIVE_INFINITY, truePeakDb: Number.NEGATIVE_INFINITY } });
  });

  it("reports a summary without true peak", () => {
    expect(parseLoudness("Summary:\n    I: -16.0 LUFS\n").ok).toBe(false);
  });
});
