export interface BrowserHostContext {
  root?: string;
  args?: readonly string[];
}

export interface EffectResolution {
  outcome: "committed" | "failed" | "uncertain";
  value: unknown;
}
