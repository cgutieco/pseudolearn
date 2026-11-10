import { describe, expect, it } from "vitest";
import { auditVideo, type VideoProbe } from "../../src/audit/video_audit.ts";
import { slot } from "../support/catalog.ts";
import { goodProbe } from "../support/probe.ts";

const preview = slot("apple.iphone.app-preview");
const search = slot("apple.search.video");

const goodPreview: VideoProbe = goodProbe({ width: 886, height: 1920 });

function rules(probe: Partial<VideoProbe>, target = preview): readonly string[] {
  return auditVideo({ slot: target, target: "piece.mp4", probe: { ...goodPreview, ...probe } }).map((entry) => entry.rule);
}

describe("auditVideo", () => {
  it("accepts a preview that matches the catalog", () => {
    expect(rules({})).toEqual([]);
  });

  it("rejects size, rotation, fps and codec mismatches", () => {
    expect(rules({ width: 1080 })).toEqual(["MEDIA-DIMENSIONS"]);
    expect(rules({ rotation: 90 })).toEqual(["MEDIA-DIMENSIONS"]);
    expect(rules({ framesPerSecond: 60 })).toEqual(["MEDIA-FPS"]);
    expect(rules({ profile: "Main" })).toEqual(["MEDIA-CODEC"]);
    expect(rules({ colorPrimaries: "unknown" })).toEqual(["MEDIA-CODEC"]);
  });

  it("enforces the duration bounds with a frame of tolerance", () => {
    expect(rules({ durationSeconds: 14.99 })).toEqual([]);
    expect(rules({ durationSeconds: 14.9 })).toEqual(["MEDIA-DURATION"]);
    expect(rules({ durationSeconds: 30.2 })).toEqual(["MEDIA-DURATION"]);
  });

  it("requires the audio track a preview needs, in the right format", () => {
    expect(rules({ audio: null })).toEqual(["MEDIA-AUDIO"]);
    expect(rules({ audio: { codec: "aac", sampleRate: 44100, channels: 2, bitrateBps: 256_000 } })).toEqual(["MEDIA-AUDIO"]);
  });

  it("forbids an audio track on the search video", () => {
    const searchProbe = { width: 3840, height: 2560 };
    expect(rules(searchProbe, search)).toEqual(["MEDIA-AUDIO"]);
    expect(rules({ ...searchProbe, audio: null }, search)).toEqual([]);
  });

  it("rejects an oversized file", () => {
    expect(rules({ sizeBytes: preview.maxBytes + 1 })).toEqual(["MEDIA-SIZE"]);
  });

  it("refuses to audit a still slot as video", () => {
    expect(rules({}, slot("apple.mac.screenshot"))).toEqual(["MEDIA-FORMAT"]);
  });
});
