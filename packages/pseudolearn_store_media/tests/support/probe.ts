import type { VideoProbe } from "../../src/audit/video_audit.ts";

const CLOSED_GOP = "IBBPBBPBBPBBPBP";

export function closedGopStructure(seconds: number): VideoProbe["delivery"]["structure"] {
  const groups = Math.round((seconds * 30) / CLOSED_GOP.length);
  return {
    pictureTypes: CLOSED_GOP.repeat(groups),
    keyFrames: Array.from({ length: groups }, (_unused, index) => index * CLOSED_GOP.length),
    boxOrder: ["ftyp", "moov", "free", "mdat"],
    editLists: 0,
  };
}

export function trailerProbe(extra: Partial<VideoProbe> = {}): VideoProbe {
  const base = goodProbe({ width: 1920, height: 1080 }, { audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 321_000 }, ...extra });
  return { ...base, delivery: { ...base.delivery, videoBitrateBps: 50_100_000, structure: closedGopStructure(base.durationSeconds) } };
}

export function goodProbe(size: { readonly width: number; readonly height: number }, extra: Partial<VideoProbe> = {}): VideoProbe {
  return {
    width: size.width,
    height: size.height,
    framesPerSecond: 30,
    durationSeconds: 15,
    codec: "h264",
    profile: "High",
    pixelFormat: "yuv420p",
    colorPrimaries: "bt709",
    rotation: 0,
    sizeBytes: 2_000_000,
    audio: { codec: "aac", sampleRate: 48000, channels: 2, bitrateBps: 250_000 },
    delivery: {
      level: 40,
      fieldOrder: "progressive",
      videoBitrateBps: 10_900_000,
      formatName: "mov,mp4,m4a,3gp,3g2,mj2",
      extension: "mp4",
      tracks: [{ kind: "video", enabled: true }, { kind: "audio", enabled: true }],
      structure: { pictureTypes: "IBBPBBP", keyFrames: [0], boxOrder: ["ftyp", "moov", "free", "mdat"], editLists: 1 },
    },
    ...extra,
  };
}
