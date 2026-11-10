import { describe, expect, it } from "vitest";
import { auditDelivery } from "../../src/audit/delivery_audit.ts";
import type { DeliveryProbe, VideoProbe } from "../../src/audit/video_audit.ts";
import { slot } from "../support/catalog.ts";
import { trailerProbe } from "../support/probe.ts";

const trailerProfile = slot("microsoft.trailer").video!.codecProfile;
const headerProfile = slot("apple.header.video").video!.codecProfile;

function rules(delivery: Partial<DeliveryProbe>, extra: Partial<VideoProbe> = {}, profile = trailerProfile): readonly string[] {
  const base = trailerProbe(extra);
  return auditDelivery({ profile, target: "piece.mp4", probe: { ...base, delivery: { ...base.delivery, ...delivery } } })
    .map((entry) => entry.rule);
}

describe("auditDelivery", () => {
  it("accepts a progressive trailer at 50 Mbps with enabled tracks in an MP4 or a MOV", () => {
    expect(rules({})).toEqual([]);
    expect(rules({ extension: "MOV", formatName: "mov,mp4,m4a,3gp,3g2,mj2" })).toEqual([]);
  });

  it("rejects interlaced and unknown scan", () => {
    expect(rules({ fieldOrder: "tt" })).toEqual(["MEDIA-CODEC"]);
    expect(rules({ fieldOrder: "" })).toEqual(["MEDIA-CODEC"]);
  });

  it("holds the trailer bitrate to 45–55 Mbps at both edges", () => {
    expect(rules({ videoBitrateBps: 45_000_000 })).toEqual([]);
    expect(rules({ videoBitrateBps: 55_000_000 })).toEqual([]);
    expect(rules({ videoBitrateBps: 714_193 })).toEqual(["MEDIA-BITRATE"]);
    expect(rules({ videoBitrateBps: 55_000_001 })).toEqual(["MEDIA-BITRATE"]);
  });

  it("leaves the bitrate free where the profile does not fix a floor", () => {
    expect(rules({ videoBitrateBps: 1, structure: { pictureTypes: "IPP", keyFrames: [0], boxOrder: ["ftyp", "moov", "mdat"], editLists: 1 } },
      { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 256_000 } }, headerProfile)).toEqual([]);
  });
});

describe("auditDelivery packaging", () => {
  it("rejects a disabled track and a container the store does not take", () => {
    expect(rules({ tracks: [{ kind: "video", enabled: true }, { kind: "audio", enabled: false }] })).toEqual(["MEDIA-TRACKS"]);
    expect(rules({ extension: "m4v" })).toEqual(["MEDIA-CONTAINER"]);
    expect(rules({ extension: "webm", formatName: "matroska,webm" })).toEqual(["MEDIA-CONTAINER"]);
    expect(rules({ extension: "" })).toEqual(["MEDIA-CONTAINER"]);
  });

  it("rejects AAC far from 320 kbps but tolerates encoder drift", () => {
    expect(rules({}, { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 300_000 } })).toEqual([]);
    expect(rules({}, { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 128_000 } })).toEqual(["MEDIA-AUDIO"]);
    expect(rules({}, { audio: null })).toEqual([]);
  });
});
