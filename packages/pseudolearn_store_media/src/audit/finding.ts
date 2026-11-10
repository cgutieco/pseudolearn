export const AUDIT_RULES = [
  "MEDIA-FORMAT",
  "MEDIA-DIMENSIONS",
  "MEDIA-ALPHA",
  "MEDIA-SIZE",
  "MEDIA-FPS",
  "MEDIA-DURATION",
  "MEDIA-CODEC",
  "MEDIA-AUDIO",
  "MEDIA-LOUDNESS",
  "MEDIA-LOOP",
  "MEDIA-SAFE-AREA",
  "MEDIA-PLATE",
  "MEDIA-TRANSITION",
  "MEDIA-APP-UI",
  "MEDIA-POSTER",
  "MEDIA-BITRATE",
  "MEDIA-TRACKS",
  "MEDIA-CONTAINER",
  "MEDIA-DISCLOSURE",
  "MEDIA-CONTENT",
  "TEXT-LEXICON",
  "TEXT-CONTRAST",
  "TEXT-FIT",
  "TEXT-READ-TIME",
  "TEXT-LENGTH",
] as const;

export type AuditRule = (typeof AUDIT_RULES)[number];

export type Finding = {
  readonly rule: AuditRule;
  readonly target: string;
  readonly message: string;
};

export function finding(rule: AuditRule, target: string, message: string): Finding {
  return { rule, target, message };
}
