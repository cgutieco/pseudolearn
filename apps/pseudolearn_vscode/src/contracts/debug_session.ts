import type { Projection } from "./worker_transport";

export interface DebugLaunch {
  program?: string;
  project?: string;
  entry?: string;
  stopOnEntry: boolean;
  profile?: "es" | "en";
  seed?: string;
  workspaceRoot?: string;
  args?: string[];
  cwd?: string;
}

export type DebugLaunchResult =
  | { ok: true; value: DebugLaunch }
  | { ok: false; reason: "target" | "entry" | "backend" | "authority" | "seed" | "options" };

export type DebugMessage = Record<string, unknown>;
export type DebugRecord = Record<string, Projection>;

export interface DebugApiPort {
  call(operation: string, argumentsValue: Record<string, unknown>): Promise<DebugRecord>;
}

export interface DebugEffectPort {
  perform(effect: DebugRecord): Promise<unknown>;
  close(): void;
}

export interface DebugSourceSnapshot {
  sourceId: number;
  path: string;
  text: string;
}

export interface DebugTarget {
  operation: "start" | "start_project";
  request: Record<string, unknown>;
  sources: DebugSourceSnapshot[];
}

export interface DebugPorts {
  api: DebugApiPort;
  effects: () => DebugEffectPort;
  prepare: (launch: Record<string, unknown>) => Promise<DebugTarget>;
}
