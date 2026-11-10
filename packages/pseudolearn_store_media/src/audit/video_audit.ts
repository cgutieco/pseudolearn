import type { Slot, VideoTraits } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";

export type AudioStreamProbe = {
  readonly codec: string;
  readonly sampleRate: number;
  readonly channels: number;
  readonly bitrateBps: number;
};

export type TrackProbe = { readonly kind: string; readonly enabled: boolean };

export type StreamStructure = {
  readonly pictureTypes: string;
  readonly keyFrames: readonly number[];
  readonly boxOrder: readonly string[];
  readonly editLists: number;
};

export const UNREAD_STRUCTURE: StreamStructure = { pictureTypes: "", keyFrames: [], boxOrder: [], editLists: 0 };

export type DeliveryProbe = {
  readonly level: number;
  readonly fieldOrder: string;
  readonly videoBitrateBps: number;
  readonly formatName: string;
  readonly extension: string;
  readonly tracks: readonly TrackProbe[];
  readonly structure: StreamStructure;
};

export type VideoProbe = {
  readonly width: number;
  readonly height: number;
  readonly framesPerSecond: number;
  readonly durationSeconds: number;
  readonly codec: string;
  readonly profile: string;
  readonly pixelFormat: string;
  readonly colorPrimaries: string;
  readonly rotation: number;
  readonly sizeBytes: number;
  readonly audio: AudioStreamProbe | null;
  readonly delivery: DeliveryProbe;
};

export type VideoAuditRequest = {
  readonly slot: Slot;
  readonly target: string;
  readonly probe: VideoProbe;
};

const DURATION_TOLERANCE_SECONDS = 0.05;

export function auditVideo(request: VideoAuditRequest): readonly Finding[] {
  const { slot, target, probe } = request;
  const video = slot.video;
  if (!video) {
    return [finding("MEDIA-FORMAT", target, `${slot.id} is not a video slot`)];
  }
  const findings: Finding[] = [];
  if (probe.width !== slot.width || probe.height !== slot.height || probe.rotation !== 0) {
    findings.push(finding("MEDIA-DIMENSIONS", target,
      `${probe.width}×${probe.height} rotated ${probe.rotation}° instead of ${slot.width}×${slot.height}`));
  }
  if (!video.acceptedFps.some((fps) => Math.abs(fps - probe.framesPerSecond) < 0.01)) {
    findings.push(finding("MEDIA-FPS", target, `${probe.framesPerSecond} fps is not accepted`));
  }
  if (probe.durationSeconds < video.duration.min - DURATION_TOLERANCE_SECONDS
    || probe.durationSeconds > video.duration.max + DURATION_TOLERANCE_SECONDS) {
    findings.push(finding("MEDIA-DURATION", target,
      `${probe.durationSeconds.toFixed(2)}s is outside ${video.duration.min}–${video.duration.max}s`));
  }
  if (probe.codec !== "h264" || probe.profile.toLowerCase() !== "high" || probe.pixelFormat !== "yuv420p"
    || probe.colorPrimaries !== "bt709") {
    findings.push(finding("MEDIA-CODEC", target,
      `${probe.codec} ${probe.profile} ${probe.pixelFormat} ${probe.colorPrimaries} is not H.264 High yuv420p bt709`));
  }
  if (probe.sizeBytes > slot.maxBytes) {
    findings.push(finding("MEDIA-SIZE", target, `${probe.sizeBytes} bytes exceeds ${slot.maxBytes}`));
  }
  return [...findings, ...audioFindings(video, probe, target)];
}

function audioFindings(video: VideoTraits, probe: VideoProbe, target: string): readonly Finding[] {
  if (video.audio === "none") {
    return probe.audio ? [finding("MEDIA-AUDIO", target, "this slot must not carry an audio track")] : [];
  }
  if (!probe.audio) {
    return [finding("MEDIA-AUDIO", target, "this slot requires an audio track")];
  }
  const expected = video.codecProfile.audio;
  if (probe.audio.codec !== expected.codec || probe.audio.sampleRate !== expected.sampleRate
    || probe.audio.channels !== expected.channels) {
    return [finding("MEDIA-AUDIO", target,
      `${probe.audio.codec} ${probe.audio.sampleRate} Hz ×${probe.audio.channels} instead of ${expected.codec} ${expected.sampleRate} Hz ×${expected.channels}`)];
  }
  return [];
}
