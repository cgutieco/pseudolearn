import type { Projection } from "../contracts/worker_transport";
import { record } from "./debug_protocol";

export function displayValue(value: Projection, ordinal: string | undefined): string {
  const fields = record(value);
  if (typeof fields?.valor === "string") return fields.valor;
  if (fields?.nulo === true) return "nulo";
  if (fields?.sin_valor === true) return "sin_valor";
  if (fields?.canal !== undefined) return displayChannel(fields.canal);
  return ordinal === undefined ? canonical(value) : `referencia(${ordinal})`;
}

function displayChannel(channel: Projection): string {
  const fields = record(channel);
  const identity = fields?.identidad;
  const queued = fields?.en_cola;
  const capacity = fields?.capacidad;
  const open = fields?.abierto;
  if (typeof identity === "string" && typeof queued === "string" && typeof capacity === "string" && typeof open === "boolean") {
    return `canal(${identity}) ${queued}/${capacity} ${open ? "abierto" : "cerrado"}`;
  }
  return canonical(channel);
}

function canonical(value: Projection): string {
  if (typeof value === "string" && /^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$/.test(value)) return value;
  return JSON.stringify(value);
}
