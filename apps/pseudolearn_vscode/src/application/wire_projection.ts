import type { Projection, WireAnswer } from "../contracts/worker_transport";

export function object(value: Projection | undefined): Record<string, Projection> {
  if (value === null || value === undefined || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Expected projected object");
  }
  return value;
}

export function answerValue(answer: WireAnswer): Record<string, Projection> {
  const envelope = object(answer.projection);
  if (envelope.failure !== undefined) {
    const failure = object(envelope.failure);
    throw new Error(String(failure.detail ?? failure.family ?? "API operation failed"));
  }
  return object(envelope.value);
}

export function text(value: Projection | undefined): string {
  if (typeof value !== "string") throw new Error("Expected projected text");
  return value;
}

export function boundedNumber(value: Projection | undefined, maximum = 2147483647): number {
  const canonical = text(value);
  const number = Number(canonical);
  if (!Number.isSafeInteger(number) || number < -2147483648 || number > maximum
    || String(number) !== canonical) throw new Error("Invalid bounded protocol number");
  return number;
}

function isProjection(value: unknown, depth = 0): boolean {
  if (depth > 128) return false;
  if (value === null || typeof value === "string" || typeof value === "boolean") return true;
  if (Array.isArray(value)) return value.every((entry) => isProjection(entry, depth + 1));
  return typeof value === "object" && Object.values(value).every((entry) => isProjection(entry, depth + 1));
}

export function parseProjection(encoded: string): Projection {
  const value: unknown = JSON.parse(encoded);
  if (!isProjection(value)) throw new Error("Invalid canonical numeric projection");
  return value as Projection;
}
