import type { CodecProfile } from "../catalog/catalog_types.ts";
import { finding, type Finding } from "./finding.ts";
import type { StreamStructure } from "./video_audit.ts";

export type StructureRequest = {
  readonly profile: CodecProfile;
  readonly target: string;
  readonly framesPerSecond: number;
  readonly structure: StreamStructure;
};

const LISTED_FRAMES = 5;

export function auditStreamStructure(request: StructureRequest): readonly Finding[] {
  return [...packagingFindings(request), ...gopFindings(request), ...bFrameFindings(request)];
}

function packagingFindings(request: StructureRequest): readonly Finding[] {
  const { profile, target, structure } = request;
  const findings: Finding[] = [];
  const movie = structure.boxOrder.indexOf("moov");
  const media = structure.boxOrder.indexOf("mdat");
  if (movie < 0 || media < 0 || movie > media) {
    findings.push(finding("MEDIA-CONTAINER", target, `boxes ${structure.boxOrder.join(" ") || "unread"} do not put moov before mdat (fast start)`));
  }
  if (profile.editLists === "forbidden" && structure.editLists > 0) {
    findings.push(finding("MEDIA-CONTAINER", target, `${structure.editLists} edit lists where the store forbids them`));
  }
  return findings;
}

function gopFindings(request: StructureRequest): readonly Finding[] {
  const { profile, target, structure } = request;
  if (profile.closedGopSeconds === null) {
    return [];
  }
  const length = Math.max(1, Math.round(request.framesPerSecond * profile.closedGopSeconds));
  const expected = Array.from({ length: Math.ceil(structure.pictureTypes.length / length) }, (_unused, index) => index * length);
  if (expected.length === 0 || expected.join(",") !== structure.keyFrames.join(",")) {
    return [finding("MEDIA-CODEC", target, `key frames at ${listed(structure.keyFrames)} instead of every ${length} frames`)];
  }
  const open = structure.keyFrames.filter((index) => index > 0 && structure.pictureTypes[index - 1] === "B");
  return open.length === 0 ? [] : [finding("MEDIA-CODEC", target, `B frames before key frames ${listed(open)} reach across the GOP`)];
}

function bFrameFindings(request: StructureRequest): readonly Finding[] {
  const { profile, target, structure } = request;
  if (profile.bFrames === null) {
    return [];
  }
  const longest = Math.max(0, ...(structure.pictureTypes.match(/B+/gu) ?? []).map((run) => run.length));
  if (longest > profile.bFrames || (profile.bFrames > 0 && longest === 0)) {
    return [finding("MEDIA-CODEC", target, `${longest} consecutive B frames instead of up to ${profile.bFrames}`)];
  }
  return [];
}

function listed(frames: readonly number[]): string {
  const shown = frames.slice(0, LISTED_FRAMES).join(", ");
  return frames.length > LISTED_FRAMES ? `${shown}, …` : shown || "none";
}
