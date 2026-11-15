import type { Projection } from "../contracts/worker_transport";
import { boundedNumber, object } from "../application/wire_projection";

export function toFetchEffect(effect: Record<string, Projection>): unknown {
  const argument = object((effect.arguments as Projection[])[0]);
  const request = { ...object(argument.value) } as Record<string, unknown>;
  for (const name of ["response_limit", "timeout_nanos", "effective_response_limit", "effective_timeout_nanos",
    "wire_limit", "header_bytes_limit", "headers_limit"]) {
    if (request[name] !== undefined && request[name] !== null) request[name] = boundedNumber(request[name] as Projection, Number.MAX_SAFE_INTEGER);
  }
  if (Array.isArray(request.body)) request.body = request.body.map((byte) => boundedNumber(byte, 255));
  return { operation: "network_send", arguments: [{ kind: "http_request", value: request }] };
}
