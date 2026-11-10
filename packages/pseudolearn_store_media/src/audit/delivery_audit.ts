import type { CodecProfile } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";
import { auditStreamStructure } from "./stream_structure_audit.ts";
import type { VideoProbe } from "./video_audit.ts";

export type DeliveryRequest = {
  readonly profile: CodecProfile;
  readonly target: string;
  readonly probe: VideoProbe;
};

export const AUDIO_BITRATE_TOLERANCE = 0.1;
const MEGABIT = 1_000_000;

export function auditDelivery(request: DeliveryRequest): readonly Finding[] {
  const { profile, target, probe } = request;
  return [...streamFindings(request), ...bitrateFindings(request), ...packagingFindings(request),
    ...auditStreamStructure({ profile, target, framesPerSecond: probe.framesPerSecond, structure: probe.delivery.structure })];
}

export function levelNumber(level: string): number {
  return Math.round(Number(level) * 10);
}

function streamFindings(request: DeliveryRequest): readonly Finding[] {
  const { profile, target, probe } = request;
  const findings: Finding[] = [];
  if (profile.level !== null && !(probe.delivery.level > 0 && probe.delivery.level <= levelNumber(profile.level))) {
    findings.push(finding("MEDIA-CODEC", target, `level ${probe.delivery.level / 10} is not within High ${profile.level}`));
  }
  if (probe.delivery.fieldOrder !== "progressive") {
    findings.push(finding("MEDIA-CODEC", target, `field order ${probe.delivery.fieldOrder || "unknown"} is not progressive`));
  }
  const audio = probe.audio;
  const expected = profile.audio.bitrateKbps * 1000;
  if (audio && Math.abs(audio.bitrateBps - expected) > expected * AUDIO_BITRATE_TOLERANCE) {
    findings.push(finding("MEDIA-AUDIO", target, `${Math.round(audio.bitrateBps / 1000)} kbps is not ${profile.audio.bitrateKbps} kbps`));
  }
  return findings;
}

function bitrateFindings(request: DeliveryRequest): readonly Finding[] {
  const { profile, target, probe } = request;
  if (profile.minBitrateMbps === null) {
    return [];
  }
  const mbps = probe.delivery.videoBitrateBps / MEGABIT;
  return mbps >= profile.minBitrateMbps && mbps <= profile.maxBitrateMbps
    ? []
    : [finding("MEDIA-BITRATE", target, `${mbps.toFixed(2)} Mbps is outside ${profile.minBitrateMbps}–${profile.maxBitrateMbps} Mbps`)];
}

function packagingFindings(request: DeliveryRequest): readonly Finding[] {
  const { profile, target, probe } = request;
  const findings: Finding[] = [];
  const disabled = probe.delivery.tracks.filter((track) => !track.enabled);
  if (disabled.length > 0) {
    findings.push(finding("MEDIA-TRACKS", target, `${disabled.map((track) => track.kind).join(", ")} track is not enabled`));
  }
  const extension = probe.delivery.extension.toLowerCase();
  if (!profile.containers.includes(extension) || !/\b(mp4|mov)\b/u.test(probe.delivery.formatName)) {
    findings.push(finding("MEDIA-CONTAINER", target, `.${extension} in ${probe.delivery.formatName} is not one of .${profile.containers.join(", .")}`));
  }
  return findings;
}
