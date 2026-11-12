import type { DebugMessage, DebugPorts, DebugRecord } from "../contracts/debug_session";
import { numeric, type NumericText } from "./canonical_arguments";
import type { DebugEffectQueue } from "./debug_effects";
import { list, naturalOf, record, wireText } from "./debug_protocol";
import { DebugReferences } from "./debug_references";
import { DebugSources } from "./debug_sources";

export interface BreakpointLocation {
  source_id: number;
  line: number;
  column?: number;
}

export interface DebugState {
  ports: DebugPorts;
  effects?: DebugEffectQueue;
  resource?: string;
  analysis?: string;
  initialized: boolean;
  configured: boolean;
  running: boolean;
  finished: boolean;
  core: DebugRecord;
  sources: DebugSources;
  references: DebugReferences;
  threads: Map<string, number>;
  inputToken?: string;
  inputGeneration: number;
  inputIdentity?: DebugRecord;
  outputBytes: number;
  pending: DebugMessage[];
  breakpoints: Map<number, BreakpointLocation[]>;
  stopOnEntry: boolean;
}

export function createState(ports: DebugPorts): DebugState {
  return { ports, initialized: false, configured: false, running: false, finished: false, core: {},
    sources: new DebugSources(), references: new DebugReferences(), threads: new Map(), inputGeneration: 0,
    outputBytes: 0, pending: [], breakpoints: new Map(), stopOnEntry: true };
}

export function execution(state: DebugState): NumericText {
  if (state.resource === undefined) throw new Error("debug session has no execution");
  return numeric(state.resource);
}

export function generation(state: DebugState): string {
  return wireText(state.core.stop_generation) ?? "0";
}

export function wireNumber(value: unknown): NumericText | null {
  return typeof value === "string" && value.length > 0 ? numeric(value) : null;
}

export async function refresh(state: DebugState): Promise<void> {
  state.core = await state.ports.api.call("debug_state", { resource: execution(state) });
  updateSources(state);
}

export function updateSources(state: DebugState): void {
  for (const entry of list(state.core.sources)) {
    const source = record(entry);
    const identifier = naturalOf(source?.source_id, -1);
    const snapshot = state.sources.snapshots.get(identifier);
    const revision = wireText(source?.revision);
    if (snapshot) snapshot.revision = revision;
  }
}

export function threadId(state: DebugState, task: string): number {
  const known = state.threads.get(task);
  if (known !== undefined) return known;
  if (state.threads.size >= 2147483646) throw new Error("debug thread identifiers exhausted");
  const assigned = state.threads.size + 1;
  state.threads.set(task, assigned);
  return assigned;
}

export function selectedTask(state: DebugState, identifier: unknown): string {
  if (identifier === undefined || identifier === null) return "0";
  if (typeof identifier !== "number" || !Number.isSafeInteger(identifier)) throw new Error("invalid thread identifier");
  for (const [task, assigned] of state.threads) {
    if (assigned === identifier) return task;
  }
  throw new Error("unknown thread identifier");
}
