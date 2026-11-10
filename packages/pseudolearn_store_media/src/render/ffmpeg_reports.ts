import type { LoudnessMeasure } from "../audit/loop_audit.ts";
import type { AudioStreamProbe, DeliveryProbe, VideoProbe } from "../audit/video_audit.ts";
import type { Outcome } from "../pipeline/ports.ts";

type Stream = {
  readonly codec_type?: string;
  readonly codec_name?: string;
  readonly profile?: string;
  readonly pix_fmt?: string;
  readonly color_primaries?: string;
  readonly width?: number;
  readonly height?: number;
  readonly r_frame_rate?: string;
  readonly sample_rate?: string;
  readonly channels?: number;
  readonly level?: number;
  readonly field_order?: string;
  readonly bit_rate?: string;
  readonly disposition?: { readonly default?: number };
  readonly tags?: Readonly<Record<string, string>>;
  readonly side_data_list?: readonly { readonly rotation?: number }[];
};

type ProbeDocument = {
  readonly streams?: readonly Stream[];
  readonly format?: { readonly duration?: string; readonly size?: string; readonly filename?: string; readonly format_name?: string };
};

export function parseProbe(text: string): Outcome<VideoProbe> {
  let document: ProbeDocument;
  try {
    document = JSON.parse(text) as ProbeDocument;
  } catch {
    return { ok: false, error: "ffprobe did not return JSON" };
  }
  const video = document.streams?.find((stream) => stream.codec_type === "video");
  if (!video) {
    return { ok: false, error: "the file has no video stream" };
  }
  const audio = document.streams?.find((stream) => stream.codec_type === "audio");
  return {
    ok: true,
    value: {
      width: video.width ?? 0,
      height: video.height ?? 0,
      framesPerSecond: rate(video.r_frame_rate ?? "0/1"),
      durationSeconds: Number(document.format?.duration ?? 0),
      codec: video.codec_name ?? "",
      profile: video.profile ?? "",
      pixelFormat: video.pix_fmt ?? "",
      colorPrimaries: video.color_primaries ?? "",
      rotation: Math.abs(video.side_data_list?.find((entry) => entry.rotation !== undefined)?.rotation ?? Number(video.tags?.["rotate"] ?? 0)),
      sizeBytes: Number(document.format?.size ?? 0),
      audio: audio ? audioOf(audio) : null,
      delivery: deliveryOf(document, video),
    },
  };
}

function deliveryOf(document: ProbeDocument, video: Stream): DeliveryProbe {
  const filename = document.format?.filename ?? "";
  return {
    level: video.level ?? 0,
    fieldOrder: video.field_order ?? "",
    videoBitrateBps: Number(video.bit_rate ?? 0),
    formatName: document.format?.format_name ?? "",
    extension: filename.includes(".") ? filename.slice(filename.lastIndexOf(".") + 1) : "",
    tracks: (document.streams ?? []).map((stream) => ({ kind: stream.codec_type ?? "unknown", enabled: stream.disposition?.default === 1 })),
  };
}

function audioOf(stream: Stream): AudioStreamProbe {
  return { codec: stream.codec_name ?? "", sampleRate: Number(stream.sample_rate ?? 0), channels: stream.channels ?? 0,
    bitrateBps: Number(stream.bit_rate ?? 0) };
}

function rate(fraction: string): number {
  const [numerator, denominator] = fraction.split("/").map(Number);
  return denominator ? (numerator ?? 0) / denominator : 0;
}

export function parseLoudness(stderr: string): Outcome<LoudnessMeasure> {
  const summary = stderr.slice(stderr.lastIndexOf("Summary:"));
  const integrated = /I:\s+(-?[\d.]+|-inf)\s+LUFS/u.exec(summary);
  const peak = /Peak:\s+(-?[\d.]+|-inf)\s+dBFS/u.exec(summary);
  if (!integrated?.[1] || !peak?.[1]) {
    return { ok: false, error: "ebur128 did not report integrated loudness and true peak" };
  }
  return { ok: true, value: { integratedLufs: decibels(integrated[1]), truePeakDb: decibels(peak[1]) } };
}

function decibels(value: string): number {
  return value === "-inf" ? Number.NEGATIVE_INFINITY : Number(value);
}
