import type { AgentCommand } from "../application/agent_service.ts";
import { AgentError } from "../domain/agent_error.ts";

export const maxBodyBytes = 1_000_000;
const maxIdentifierLength = 128;

export function bearerTokenOf(request: Request): string {
  const header = request.headers.get("authorization");
  const [scheme, token, ...rest] = (header ?? "").trim().split(" ");
  if (scheme?.toLowerCase() !== "bearer" || rest.length > 0 || !token) {
    throw new AgentError("unauthenticated");
  }
  return token;
}

export function requestIdOf(request: Request): string {
  return identifierOf(request.headers.get("x-request-id"), "x-request-id");
}

export async function parseAgentRequest(request: Request): Promise<AgentCommand> {
  if (request.method !== "POST") throw new AgentError("method_not_allowed");
  const accessToken = bearerTokenOf(request);
  const requestId = requestIdOf(request);
  const turnId = identifierOf(request.headers.get("x-pseudolearn-turn-id"), "turn");
  return { accessToken, requestId, turnId, body: await jsonBodyOf(request) };
}

export async function jsonBodyOf(request: Request): Promise<unknown> {
  const text = await request.text();
  if (new TextEncoder().encode(text).length > maxBodyBytes) {
    throw new AgentError("payload_too_large");
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new AgentError("invalid_request", "json");
  }
}

function identifierOf(value: string | null, name: string): string {
  const trimmed = value?.trim() ?? "";
  if (trimmed.length === 0 || trimmed.length > maxIdentifierLength) {
    throw new AgentError("invalid_request", name);
  }
  return trimmed;
}
