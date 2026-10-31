export interface FileGrant {
  root: string;
  writable: boolean;
  confined: boolean;
}

export interface BrowserGrants {
  origins: string[];
  files?: FileGrant;
}

export interface EffectResolution {
  outcome: "committed" | "failed" | "uncertain";
  value: unknown;
}
