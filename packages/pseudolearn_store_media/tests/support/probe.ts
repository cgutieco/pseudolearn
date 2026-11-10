import type { VideoProbe } from "../../src/audit/video_audit.ts";

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
    },
    ...extra,
  };
}
