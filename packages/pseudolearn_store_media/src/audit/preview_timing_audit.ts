import { finding, type Finding } from "./finding.ts";

export type SceneSpan = {
  readonly label: string;
  readonly startSeconds: number;
  readonly endSeconds: number;
  readonly dissolveSeconds: number;
  readonly trimEndSeconds: number;
  readonly plateSeconds: number;
};

export type TextSpan = {
  readonly text: string;
  readonly startSeconds: number;
  readonly endSeconds: number;
  readonly sceneStartSeconds: number;
  readonly sceneEndSeconds: number;
};

export const DISSOLVE_RANGE = { min: 0.4, max: 1.5 };
export const MINIMUM_SOLO_SECONDS = 2;
export const MINIMUM_READ_SECONDS = 2;
export const READ_LEAD_SECONDS = 1;
export const WORDS_PER_SECOND = 3;

export function auditSceneSpans(spans: readonly SceneSpan[]): readonly Finding[] {
  return spans.flatMap((span, index) => {
    const findings: Finding[] = [];
    if (index > 0 && (span.dissolveSeconds < DISSOLVE_RANGE.min || span.dissolveSeconds > DISSOLVE_RANGE.max)) {
      findings.push(finding("MEDIA-TRANSITION", span.label,
        `a ${span.dissolveSeconds}s dissolve is outside ${DISSOLVE_RANGE.min}–${DISSOLVE_RANGE.max}s`));
    }
    const solo = span.endSeconds - span.startSeconds - span.dissolveSeconds - (spans[index + 1]?.dissolveSeconds ?? 0);
    if (solo < MINIMUM_SOLO_SECONDS) {
      findings.push(finding("MEDIA-TRANSITION", span.label,
        `holds alone for ${solo.toFixed(2)}s, under the ${MINIMUM_SOLO_SECONDS}s that avoids rapid cuts`));
    }
    if (span.trimEndSeconds > span.plateSeconds + 1e-6) {
      findings.push(finding("MEDIA-PLATE", span.label,
        `asks for the plate up to ${span.trimEndSeconds}s but it lasts ${span.plateSeconds.toFixed(2)}s`));
    }
    return findings;
  });
}

export function readingSeconds(text: string): number {
  const words = text.replaceAll("*", "").split(/\s+/u).filter((word) => word.length > 0).length;
  return Math.max(MINIMUM_READ_SECONDS, READ_LEAD_SECONDS + words / WORDS_PER_SECOND);
}

export function auditReadingTime(spans: readonly TextSpan[]): readonly Finding[] {
  return spans.flatMap((span) => {
    const findings: Finding[] = [];
    const shown = span.endSeconds - span.startSeconds;
    const needed = readingSeconds(span.text);
    if (shown + 1e-6 < needed) {
      findings.push(finding("TEXT-READ-TIME", span.text, `is on screen ${shown.toFixed(2)}s but needs ${needed.toFixed(2)}s to be read`));
    }
    if (span.startSeconds < span.sceneStartSeconds - 1e-6 || span.endSeconds > span.sceneEndSeconds + 1e-6) {
      findings.push(finding("TEXT-READ-TIME", span.text, "outlives the scene that shows it"));
    }
    return findings;
  });
}
