import type { DebugMessage } from "../contracts/debug_session";
import { argument, event, wireText } from "./debug_protocol";
import { terminate } from "./debug_lifecycle";
import { type DebugState, execution, refresh, selectedTask, threadId, wireNumber } from "./debug_state";

const conditions: Record<string, string> = {
  continue: "continue", next: "next", stepIn: "step_in", stepOut: "step_out", stepBack: "step_back",
};

export async function control(state: DebugState, request: DebugMessage): Promise<unknown> {
  const command = String(request.command ?? "");
  if (command === "pseudolearn/input") return input(state, request);
  if (!state.configured) throw new Error("debug execution is not configured");
  if (command === "pause") return pause(state);
  if (state.running) throw new Error("another debug control is active");
  const task = selectedTask(state, argument(request, "threadId"));
  const condition = conditions[command];
  if (condition === undefined) throw new Error("unsupported control");
  state.core = await state.ports.api.call("debug_control", { resource: execution(state), command: condition, task_id: wireNumber(task) });
  state.references.clear();
  state.running = true;
  state.pending.push(event("continued", { threadId: threadId(state, task), allThreadsContinued: true }));
  return { allThreadsContinued: true };
}

async function pause(state: DebugState): Promise<unknown> {
  if (!state.running) throw new Error("debug execution is already paused");
  await state.ports.api.call("debug_control", { resource: execution(state), command: "pause" });
  state.running = false;
  await refresh(state);
  stopped(state, "pause");
  return {};
}

async function input(state: DebugState, request: DebugMessage): Promise<unknown> {
  const token = argument(request, "token");
  if (typeof token !== "string") throw new Error("missing input token");
  if (state.inputToken !== token) throw new Error("stale input token");
  const action = argument(request, "action");
  if (action === "cancel") {
    state.inputToken = undefined;
    await terminate(state);
    return {};
  }
  if (action !== "line") throw new Error("invalid input action");
  const text = argument(request, "text");
  if (typeof text !== "string") throw new Error("missing input line");
  const identity = state.inputIdentity ?? {};
  await state.ports.api.call("input", { resource: execution(state), text, resource_id: wireNumber(identity.resource_id),
    task_id: wireNumber(identity.task_id), request_id: wireNumber(identity.request_id) });
  state.inputToken = undefined;
  return {};
}

export function stopped(state: DebugState, reason: string): void {
  const task = wireText(state.core.task_id) ?? "0";
  state.pending.push(event("stopped", { reason, threadId: threadId(state, task), allThreadsStopped: true, preserveFocusHint: false }));
}
