import { type AgentDependencies, respondWithModel } from "../application/agent_service.ts";
import { AgentError, type AgentErrorCode } from "../domain/agent_error.ts";
import { asAgentError, balanceHeaders, errorResponse } from "./agent_envelope.ts";
import { parseAgentRequest } from "./agent_request.ts";

export type AgentSetup =
  | { readonly kind: "ready"; readonly dependencies: AgentDependencies }
  | { readonly kind: "unavailable"; readonly code: AgentErrorCode };

export interface AgentEvent {
  readonly event: string;
  readonly status: number;
  readonly code: string;
  readonly milliseconds: number;
}

export type EventRecorder = (event: AgentEvent) => void;

export function createAgentHandler(
  setup: AgentSetup,
  record: EventRecorder,
  elapsed: () => number,
): (request: Request) => Promise<Response> {
  return async (request) => {
    const started = elapsed();
    const response = await answer(request, setup);
    const code = response.status === 200 ? "ok" : await errorCodeOf(response);
    record({
      event: "agent_responses",
      status: response.status,
      code,
      milliseconds: elapsed() - started,
    });
    return response;
  };
}

async function answer(request: Request, setup: AgentSetup): Promise<Response> {
  const requestId = request.headers.get("x-request-id");
  try {
    if (request.method !== "POST") throw new AgentError("method_not_allowed");
    if (setup.kind === "unavailable") throw new AgentError(setup.code);
    const reply = await respondWithModel(await parseAgentRequest(request), setup.dependencies);
    return new Response(reply.body, {
      status: 200,
      headers: {
        "content-type": "application/json",
        "x-request-id": requestId ?? "",
        ...balanceHeaders(reply.balance),
      },
    });
  } catch (error) {
    return errorResponse(asAgentError(error), requestId);
  }
}

async function errorCodeOf(response: Response): Promise<string> {
  try {
    const body = await response.clone().json();
    return typeof body?.error?.code === "string" ? body.error.code : "unknown";
  } catch {
    return "unknown";
  }
}
