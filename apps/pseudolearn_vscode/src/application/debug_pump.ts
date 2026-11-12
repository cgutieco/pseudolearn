import type { DebugRecord } from "../contracts/debug_session";
import { numeric } from "./canonical_arguments";
import { stopped } from "./debug_control";
import { terminate } from "./debug_lifecycle";
import { byteLength, errorRanges, outputSegments } from "./debug_output";
import { event, list, record, wireText } from "./debug_protocol";
import { type DebugState, execution, generation, refresh, updateSources } from "./debug_state";

export async function pumpBatch(state: DebugState): Promise<void> {
  if (state.finished || state.resource === undefined) return;
  await deliverEffects(state);
  if (!state.running || state.inputToken !== undefined || state.effects?.isPending()) return;
  const batch = await state.ports.api.call("advance", { resource: execution(state), batch_size: 64 });
  presentOutput(state, batch);
  await presentBatch(state, batch);
}

async function deliverEffects(state: DebugState): Promise<void> {
  for (const completed of state.effects?.take() ?? []) {
    await state.ports.api.call("effect_result", { resource: execution(state), effect_seq: numeric(completed.sequence),
      result: completed.result });
  }
}

async function presentBatch(state: DebugState, batch: DebugRecord): Promise<void> {
  const debug = record(batch.debug);
  if (debug) {
    state.core = debug;
    updateSources(state);
  } else await refresh(state);
  if (state.core.stopped === true) {
    state.running = false;
    stopped(state, wireText(state.core.reason) ?? "step");
    return;
  }
  const kind = wireText(record(batch.termination)?.kind) ?? "failed";
  if (kind === "running") return;
  if (kind === "awaiting_input") return awaitInput(state, batch);
  if (kind === "awaiting_effect") return dispatchEffects(state, batch);
  state.pending.push(event("exited", { exitCode: kind === "completed" ? 0 : 1 }));
  await terminate(state);
}

function presentOutput(state: DebugState, batch: DebugRecord): void {
  const output = wireText(batch.output) ?? "";
  for (const [category, text] of outputSegments(output, state.outputBytes, errorRanges(batch.error_ranges))) {
    state.pending.push(event("output", { category, output: text }));
  }
  state.outputBytes = Math.max(state.outputBytes, byteLength(output));
}

function awaitInput(state: DebugState, batch: DebugRecord): void {
  state.inputGeneration += 1;
  const token = `${state.resource}:${generation(state)}:${state.inputGeneration}`;
  state.inputToken = token;
  state.inputIdentity = record(batch.pending_input);
  state.pending.push(event("pseudolearn/awaitingInput", { token }));
}

function dispatchEffects(state: DebugState, batch: DebugRecord): void {
  const effects = Array.isArray(batch.pending_effects) ? list(batch.pending_effects) : [batch.pending_effect];
  for (const entry of effects) {
    const effect = record(entry);
    if (!effect) continue;
    if (!state.effects) throw new Error("no physical effect provider is granted");
    if (!state.effects.submit(effect) || effect.operation !== "console_write") continue;
    const text = wireText(record(list(effect.arguments)[0])?.value) ?? "";
    state.pending.push(event("output", { category: "stdout", output: text }));
  }
}
