import type { WorkerEnvelope } from "../contracts/worker_transport";

export const maximumPayloadBytes = 8 * 1024 * 1024;
export const maximumPendingRequests = 8;
export const maximumPendingNotifications = 256;

export function validateEnvelope(value: unknown): WorkerEnvelope | undefined {
  if (value === null || typeof value !== "object") return undefined;
  const envelope = value as WorkerEnvelope;
  if (envelope.schema !== 1 || !["language", "execution"].includes(envelope.channel)) return undefined;
  if (!["initialize", "ready", "call", "result", "failure", "close"].includes(envelope.kind)) return undefined;
  if (typeof envelope.session !== "string" || envelope.session.length > 128) return undefined;
  if (!Number.isSafeInteger(envelope.generation) || envelope.generation < 1) return undefined;
  if (!Number.isSafeInteger(envelope.request) || envelope.request < 0) return undefined;
  if (typeof envelope.payload !== "string") return undefined;
  if (new TextEncoder().encode(envelope.payload).length > maximumPayloadBytes) return undefined;
  if (envelope.projection !== undefined && (typeof envelope.projection !== "string"
    || new TextEncoder().encode(envelope.projection).length > maximumPayloadBytes)) return undefined;
  return envelope;
}
