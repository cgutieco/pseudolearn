export interface DebugLaunch {
  program?: string;
  project?: string;
  entry?: string;
  stopOnEntry: boolean;
  profile?: "es" | "en";
  strictness?: "strict" | "flexible";
  seed?: string;
  workspaceRoot?: string;
}

export type DebugLaunchResult =
  | { ok: true; value: DebugLaunch }
  | { ok: false; reason: "target" | "entry" | "backend" | "authority" | "seed" | "options" };
