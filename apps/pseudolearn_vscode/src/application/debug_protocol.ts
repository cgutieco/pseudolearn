import type { DebugMessage, DebugRecord } from "../contracts/debug_session";
import type { Projection } from "../contracts/worker_transport";

export const debugCapabilities = {
  supportsConfigurationDoneRequest: true,
  supportsTerminateRequest: true,
  supportsEvaluateForHovers: true,
  supportsStepBack: true,
  supportsDelayedStackTraceLoading: true,
  supportsValueFormattingOptions: false,
  supportsSingleThreadExecutionRequests: false,
  supportsLoadedSourcesRequest: true,
};

export type DebugOutcome = { ok: true; body: unknown } | { ok: false; message: string };

export function response(request: DebugMessage, outcome: DebugOutcome): DebugMessage {
  const message: DebugMessage = { type: "response", request_seq: request.seq, command: request.command, success: outcome.ok };
  if (outcome.ok) message.body = outcome.body;
  else message.message = outcome.message;
  return message;
}

export function event(name: string, body: unknown): DebugMessage {
  return { type: "event", event: name, body };
}

export function argument(request: DebugMessage, name: string): unknown {
  const values = request.arguments;
  if (values === null || typeof values !== "object") return undefined;
  return (values as Record<string, unknown>)[name];
}

export function naturalOf(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isSafeInteger(value) && value >= 0) return value;
  if (typeof value === "string" && /^(0|[1-9][0-9]*)$/.test(value) && Number.isSafeInteger(Number(value))) return Number(value);
  return fallback;
}

export function record(value: Projection | undefined): DebugRecord | undefined {
  return value !== null && typeof value === "object" && !Array.isArray(value) ? value : undefined;
}

export function list(value: Projection | undefined): Projection[] {
  return Array.isArray(value) ? value : [];
}

export function wireText(value: Projection | undefined): string | undefined {
  return typeof value === "string" ? value : undefined;
}
