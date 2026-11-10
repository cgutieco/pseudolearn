import { describe, expect, it } from "vitest";
import { auditDelivery, levelNumber } from "../../src/audit/delivery_audit.ts";
import type { DeliveryProbe, VideoProbe } from "../../src/audit/video_audit.ts";
import { slot } from "../support/catalog.ts";
import { goodProbe } from "../support/probe.ts";

const previewProfile = slot("apple.iphone.app-preview").video!.codecProfile;
const headerProfile = slot("apple.header.video").video!.codecProfile;

function rules(delivery: Partial<DeliveryProbe>, extra: Partial<VideoProbe> = {}, profile = previewProfile): readonly string[] {
  const base = goodProbe({ width: 886, height: 1920 }, extra);
  return auditDelivery({ profile, target: "piece.mp4", probe: { ...base, delivery: { ...base.delivery, ...delivery } } })
    .map((entry) => entry.rule);
}

describe("auditDelivery", () => {
  it("accepts a progressive High 4.0 file at 10.9 Mbps with enabled tracks in an MP4", () => {
    expect(rules({})).toEqual([]);
    expect(rules({ extension: "MOV", formatName: "mov,mp4,m4a,3gp,3g2,mj2" })).toEqual([]);
  });

  it("reads catalog levels as ffprobe numbers", () => {
    expect(levelNumber("4.0")).toBe(40);
    expect(levelNumber("3.1")).toBe(31);
  });

  it("rejects a level above 4.0, an unknown level and interlaced scan", () => {
    expect(rules({ level: 41 })).toEqual(["MEDIA-CODEC"]);
    expect(rules({ level: 0 })).toEqual(["MEDIA-CODEC"]);
    expect(rules({ fieldOrder: "tt" })).toEqual(["MEDIA-CODEC"]);
    expect(rules({ fieldOrder: "" })).toEqual(["MEDIA-CODEC"]);
  });

  it("holds the video bitrate to 10–12 Mbps at both edges", () => {
    expect(rules({ videoBitrateBps: 10_000_000 })).toEqual([]);
    expect(rules({ videoBitrateBps: 12_000_000 })).toEqual([]);
    expect(rules({ videoBitrateBps: 714_193 })).toEqual(["MEDIA-BITRATE"]);
    expect(rules({ videoBitrateBps: 12_000_001 })).toEqual(["MEDIA-BITRATE"]);
  });

  it("leaves the bitrate free and skips the level where the profile does not fix them", () => {
    expect(rules({ videoBitrateBps: 1, level: 52 }, {}, headerProfile)).toEqual([]);
  });

});

describe("auditDelivery packaging", () => {
  it("rejects a disabled track and a container Apple does not take", () => {
    expect(rules({ tracks: [{ kind: "video", enabled: true }, { kind: "audio", enabled: false }] })).toEqual(["MEDIA-TRACKS"]);
    expect(rules({ extension: "webm", formatName: "matroska,webm" })).toEqual(["MEDIA-CONTAINER"]);
    expect(rules({ extension: "" })).toEqual(["MEDIA-CONTAINER"]);
  });

  it("rejects AAC far from 256 kbps but tolerates encoder drift", () => {
    expect(rules({}, { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 236_000 } })).toEqual([]);
    expect(rules({}, { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 128_000 } })).toEqual(["MEDIA-AUDIO"]);
    expect(rules({}, { audio: null })).toEqual([]);
  });
});
