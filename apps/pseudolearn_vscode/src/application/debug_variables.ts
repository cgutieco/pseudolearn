import type { DebugMessage, DebugRecord } from "../contracts/debug_session";
import type { Projection } from "../contracts/worker_transport";
import { numeric } from "./canonical_arguments";
import { argument, naturalOf, record, wireText } from "./debug_protocol";
import { type DebugState, execution, generation, wireNumber } from "./debug_state";
import { displayValue } from "./debug_values";

export async function variables(state: DebugState, request: DebugMessage): Promise<unknown> {
  const reference = state.references.variables(argument(request, "variablesReference"), generation(state));
  const start = naturalOf(argument(request, "start"), 0);
  const requested = naturalOf(argument(request, "count"), 0);
  const count = requested === 0 ? 4096 : requested;
  if (count > 4096) throw new Error("variable page exceeds 4096 values");
  const page = await state.ports.api.call("query_page", { resource: execution(state), event: wireNumber(state.core.event),
    task_id: numeric(reference.task), target: numeric(reference.target), query: reference.query, page_size: count, offset: start });
  const filter = argument(request, "filter");
  const indexed = page.indexed === true;
  if ((filter === "named" && indexed) || (filter === "indexed" && !indexed)) return { variables: [] };
  if (!Array.isArray(page.elements)) throw new Error("missing page elements");
  return { variables: page.elements.map((element, index) => presentVariable(state, reference.task, element, start + index)) };
}

function presentVariable(state: DebugState, task: string, element: Projection, position: number): unknown {
  const fields = record(element);
  const name = wireText(fields?.name) ?? String(position);
  const value = fields?.value ?? element;
  const ordinal = wireText(record(value)?.ref);
  const variablesReference = ordinal === undefined ? 0 : objectReference(state, task, ordinal);
  return { name, value: displayValue(value, ordinal), type: record(value)?.tipo ?? null, variablesReference };
}

function objectReference(state: DebugState, task: string, target: string): number {
  return state.references.allocate({ kind: "variables", task, target, query: "object_fields", generation: generation(state) });
}

export async function evaluate(state: DebugState, request: DebugMessage): Promise<unknown> {
  const context = argument(request, "context") ?? "watch";
  if (typeof context !== "string" || !["hover", "watch", "repl"].includes(context)) throw new Error("unsupported evaluate context");
  const frame = state.references.frame(argument(request, "frameId"), generation(state));
  const expression = argument(request, "expression");
  if (typeof expression !== "string") throw new Error("missing inspection expression");
  const value: DebugRecord = await state.ports.api.call("inspect_expression", { resource: execution(state),
    event: wireNumber(state.core.event), task_id: numeric(frame.task), frame: numeric(frame.position), expression });
  const target = wireText(value.reference);
  const variablesReference = target === undefined ? 0 : objectReference(state, frame.task, target);
  return { result: value.value ?? null, type: value.type ?? null, variablesReference };
}
