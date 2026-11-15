import type { DebugMessage } from "../contracts/debug_session";
import type { Projection } from "../contracts/worker_transport";
import { argument, list, naturalOf, record, wireText } from "./debug_protocol";
import { type DebugState, execution, generation, refresh, selectedTask, threadId, wireNumber } from "./debug_state";
import { evaluate, variables } from "./debug_variables";

export async function inspect(state: DebugState, request: DebugMessage): Promise<unknown> {
  const command = String(request.command ?? "");
  execution(state);
  if (command === "source") return source(state, request);
  if (command === "loadedSources") return { sources: [...state.sources.snapshots.keys()].map((key) => state.sources.describe(key)) };
  if (state.running) throw new Error("inspection requires a paused execution");
  if (command === "threads") return listThreads(state);
  if (command === "stackTrace") return stack(state, request);
  if (command === "scopes") return scopes(state, request);
  if (command === "variables") return variables(state, request);
  if (command === "evaluate") return evaluate(state, request);
  throw new Error("unsupported inspection");
}

function source(state: DebugState, request: DebugMessage): unknown {
  const reference = argument(request, "sourceReference");
  const wanted = reference === undefined || reference === null ? argument(request, "source") : { sourceReference: reference };
  const snapshot = state.sources.snapshots.get(state.sources.identifier(wanted));
  if (!snapshot) throw new Error("unknown source");
  return { content: snapshot.text, mimeType: "text/x-pseudolearn" };
}

async function listThreads(state: DebugState): Promise<unknown> {
  await refresh(state);
  const threads = list(state.core.threads).map((entry) => {
    const task = wireText(record(entry)?.id);
    if (task === undefined) throw new Error("invalid core task identity");
    return { id: threadId(state, task), name: wireText(record(entry)?.name) ?? "PseudoLearn task" };
  });
  return { threads };
}

async function stack(state: DebugState, request: DebugMessage): Promise<unknown> {
  const task = selectedTask(state, argument(request, "threadId"));
  const start = naturalOf(argument(request, "startFrame"), 0);
  const requested = naturalOf(argument(request, "levels"), 0);
  const count = requested === 0 ? 4096 : requested;
  if (count > 4096) throw new Error("stack page exceeds 4096 frames");
  const page = await state.ports.api.call("debug_state", { resource: execution(state), task_id: wireNumber(task),
    start_frame: start, frame_count: count });
  if (!Array.isArray(page.frames)) throw new Error("missing core frames");
  const stackFrames = page.frames.map((frame) => stackFrame(state, task, frame));
  return { stackFrames, totalFrames: naturalOf(page.total_frames, stackFrames.length) };
}

function stackFrame(state: DebugState, task: string, frame: Projection): unknown {
  const fields = record(frame) ?? {};
  const position = wireText(fields.id);
  if (position === undefined) throw new Error("missing frame identity");
  const identifier = state.references.allocate({ kind: "frame", task, position, generation: generation(state) });
  const sourceId = naturalOf(fields.source_id, -1);
  if (sourceId < 0) throw new Error("missing frame source");
  const [line, column] = state.sources.location(sourceId, naturalOf(fields.line, 1), naturalOf(fields.column, 1));
  return { id: identifier, name: fields.name ?? null, source: state.sources.describe(sourceId), line, column, presentationHint: "normal" };
}

function scopes(state: DebugState, request: DebugMessage): unknown {
  const frame = state.references.frame(argument(request, "frameId"), generation(state));
  const reference = state.references.allocate({ kind: "variables", task: frame.task, target: frame.position,
    query: "frame_variables", generation: generation(state) });
  return { scopes: [{ name: "Locals", presentationHint: "locals", variablesReference: reference, expensive: false }] };
}
