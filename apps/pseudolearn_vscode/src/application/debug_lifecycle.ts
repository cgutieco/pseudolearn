import type { DebugMessage, DebugTarget } from "../contracts/debug_session";
import { numeric } from "./canonical_arguments";
import { DebugEffectQueue } from "./debug_effects";
import { argument, debugCapabilities, event, wireText } from "./debug_protocol";
import { type DebugState, execution, refresh } from "./debug_state";

export function initialize(state: DebugState, request: DebugMessage): unknown {
  if (state.initialized || state.finished) throw new Error("debug session is already initialized");
  const format = argument(request, "pathFormat");
  if (format !== undefined && format !== "path") throw new Error("only path source format is supported");
  state.sources.linesStartAtOne = argument(request, "linesStartAt1") !== false;
  state.sources.columnsStartAtOne = argument(request, "columnsStartAt1") !== false;
  state.initialized = true;
  return debugCapabilities;
}

export async function launch(state: DebugState, request: DebugMessage): Promise<unknown> {
  if (!state.initialized || state.resource !== undefined || state.finished) throw new Error("launch is invalid in the current state");
  const launchArguments = (request.arguments ?? {}) as Record<string, unknown>;
  try {
    await start(state, await state.ports.prepare(launchArguments));
    state.effects = new DebugEffectQueue(state.ports.effects());
    state.stopOnEntry = launchArguments.stopOnEntry !== false;
    await state.ports.api.call("debug_configure", { resource: execution(state), breakpoints: [], stop_on_entry: state.stopOnEntry });
    await refresh(state);
  } catch (error) {
    await close(state);
    throw error;
  }
  state.pending.push(event("initialized", {}));
  return {};
}

async function start(state: DebugState, target: DebugTarget): Promise<void> {
  let request = target.request;
  if (target.operation === "start") {
    const analysis = await state.ports.api.call("create_analysis", request);
    state.analysis = wireText(analysis.resource);
    if (state.analysis === undefined) throw new Error("missing analysis");
    request = { ...request, analysis: numeric(state.analysis) };
  }
  const started = await state.ports.api.call(target.operation, request);
  state.resource = wireText(started.resource);
  if (state.resource === undefined) throw new Error("program was rejected");
  for (const source of target.sources) state.sources.snapshots.set(source.sourceId, { ...source });
}

export async function configurationDone(state: DebugState): Promise<unknown> {
  if (state.resource === undefined || state.configured || state.finished) {
    throw new Error("configurationDone is invalid in the current state");
  }
  state.configured = true;
  await state.ports.api.call("debug_control", { resource: execution(state), command: "continue" });
  state.running = true;
  return {};
}

export async function close(state: DebugState): Promise<void> {
  state.running = false;
  state.inputToken = undefined;
  state.references.clear();
  state.sources.snapshots.clear();
  state.breakpoints.clear();
  state.effects?.close();
  state.effects = undefined;
  const api = state.ports.api;
  const resource = state.resource;
  state.resource = undefined;
  if (resource !== undefined) {
    const handle = { resource: numeric(resource) };
    await api.call("cancel", handle).catch(() => undefined);
    await api.call("advance", { ...handle, batch_size: 1 }).catch(() => undefined);
    await api.call("release", handle).catch(() => undefined);
  }
  for (const document of [state.analysis]) {
    if (document !== undefined) await api.call("release", { resource: numeric(document) }).catch(() => undefined);
  }
  state.analysis = undefined;
}

export async function terminate(state: DebugState): Promise<void> {
  if (state.finished) return;
  await close(state);
  state.finished = true;
  state.pending.push(event("terminated", {}));
}
