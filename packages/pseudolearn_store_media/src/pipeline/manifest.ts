import type { Finding } from "../audit/finding.ts";
import type { Job } from "./render_plan.ts";

export type Manifest = {
  readonly piece: string;
  readonly slot: string;
  readonly language: string;
  readonly locales: readonly string[];
  readonly file: string | null;
  readonly sha256: string | null;
  readonly checkedFrames: number;
  readonly findings: readonly Finding[];
};

export type ManifestParts = {
  readonly piece: string;
  readonly job: Job;
  readonly file: string | null;
  readonly sha256: string | null;
  readonly checkedFrames: number;
  readonly findings: readonly Finding[];
};

export function manifestOf(parts: ManifestParts): Manifest {
  return {
    piece: parts.piece,
    slot: parts.job.slot.id,
    language: parts.job.language,
    locales: parts.job.locales,
    file: parts.file,
    sha256: parts.sha256,
    checkedFrames: parts.checkedFrames,
    findings: parts.findings,
  };
}

export function isAccepted(manifest: Manifest): boolean {
  return manifest.file !== null && manifest.findings.length === 0;
}
