import type { DebugMessage } from "../contracts/debug_session";
import type { Projection } from "../contracts/worker_transport";
import { argument, list, naturalOf, record } from "./debug_protocol";
import { type BreakpointLocation, type DebugState, execution } from "./debug_state";

const maximumBreakpoints = 4096;

export async function setBreakpoints(state: DebugState, request: DebugMessage): Promise<unknown> {
  execution(state);
  const source = state.sources.identifier(argument(request, "source"));
  const requested = argument(request, "breakpoints");
  const locations = Array.isArray(requested) ? requested : [];
  if (locations.length > maximumBreakpoints) throw new Error("breakpoint limit exceeded");
  const modified = argument(request, "sourceModified") === true;
  const accepted: BreakpointLocation[] = [];
  const rejected: Array<string | undefined> = locations.map((location) => {
    try {
      accepted.push(breakpointLocation(state, source, location, modified));
      return undefined;
    } catch (error) {
      return error instanceof Error ? error.message : String(error);
    }
  });
  state.breakpoints.set(source, accepted);
  return configure(state, source, rejected);
}

function breakpointLocation(state: DebugState, source: number, location: unknown, modified: boolean): BreakpointLocation {
  if (modified) throw new Error("source differs from the execution snapshot");
  const fields = location !== null && typeof location === "object" ? location as Record<string, unknown> : {};
  if (["condition", "hitCondition", "logMessage"].some((field) => fields[field] !== undefined)) {
    throw new Error("conditional and log breakpoints are unavailable");
  }
  if (typeof fields.line !== "number" || !Number.isSafeInteger(fields.line) || fields.line < 0) throw new Error("missing breakpoint line");
  const column = naturalOf(fields.column, state.sources.columnsStartAtOne ? 1 : 0);
  const [line, coreColumn] = state.sources.coreLocation(source, fields.line, column);
  return fields.column === undefined ? { source_id: source, line } : { source_id: source, line, column: coreColumn };
}

async function configure(state: DebugState, source: number, rejected: Array<string | undefined>): Promise<unknown> {
  const all = [...state.breakpoints.values()].flat();
  const configured = await state.ports.api.call("debug_configure", { resource: execution(state), breakpoints: all,
    stop_on_entry: state.stopOnEntry });
  const resolved = list(configured.breakpoints).filter((point) => naturalOf(record(point)?.source_id, -1) === source);
  let next = 0;
  const breakpoints = rejected.map((reason) => {
    if (reason !== undefined) return { verified: false, message: reason };
    return presentBreakpoint(state, source, resolved[next++]);
  });
  return { breakpoints };
}

function presentBreakpoint(state: DebugState, source: number, point: Projection | undefined): unknown {
  const fields = record(point);
  if (!fields) return { verified: false, message: "no executable statement at location" };
  const [line, column] = state.sources.location(source, naturalOf(fields.line, 1), naturalOf(fields.column, 1));
  const presented: Record<string, unknown> = { ...fields, line, column, source: state.sources.describe(source) };
  for (const numericField of ["id", "source_id"]) {
    const value = fields[numericField];
    if (typeof value === "string") presented[numericField] = naturalOf(value, 0);
  }
  return presented;
}
