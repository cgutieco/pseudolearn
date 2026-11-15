import type { FinishStatus, RunCommand, RunEvent, RunSource } from "../contracts/editor_run";

const finishStatuses: readonly string[] = [
  "completed",
  "failed",
  "cancelled",
  "input_closed",
  "output_limit",
  "protocol_error",
];

export const supportedSchema = 1;

export function parseRunEvent(line: string): RunEvent | undefined {
  let document: unknown;
  try {
    document = JSON.parse(line);
  } catch {
    return undefined;
  }
  if (typeof document !== "object" || document === null) {
    return undefined;
  }
  return interpret(document as Record<string, unknown>);
}

function interpret(fields: Record<string, unknown>): RunEvent | undefined {
  switch (fields.event) {
    case "hello":
      return typeof fields.schema === "number" ? { event: "hello", schema: fields.schema } : undefined;
    case "output":
      return typeof fields.text === "string" ? { event: "output", text: fields.text } : undefined;
    case "awaiting_input":
      return { event: "awaiting_input" };
    case "diagnostics":
      return interpretDiagnostics(fields);
    case "protocol_error":
      return typeof fields.reason === "string" ? { event: "protocol_error", reason: fields.reason } : undefined;
    case "finished":
      return interpretFinished(fields);
    default:
      return undefined;
  }
}

function interpretDiagnostics(fields: Record<string, unknown>): RunEvent | undefined {
  if (!Array.isArray(fields.diagnostics) || !Array.isArray(fields.project_errors)) {
    return undefined;
  }
  return {
    event: "diagnostics",
    diagnostics: fields.diagnostics,
    projectErrors: fields.project_errors,
    sources: sourcesOf(fields.sources),
  };
}

function sourcesOf(value: unknown): RunSource[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.flatMap((entry: Record<string, unknown>) =>
    typeof entry?.source_id === "number" && typeof entry.path === "string"
      ? [{ sourceId: entry.source_id, path: entry.path }]
      : [],
  );
}

function interpretFinished(fields: Record<string, unknown>): RunEvent | undefined {
  const { status, termination, exit_code: exitCode } = fields;
  if (typeof status !== "string" || !finishStatuses.includes(status) || typeof exitCode !== "number") {
    return undefined;
  }
  return {
    event: "finished",
    status: status as FinishStatus,
    termination: typeof termination === "string" ? termination : null,
    exitCode,
  };
}

export function encodeRunCommand(command: RunCommand): string {
  return JSON.stringify(command);
}
