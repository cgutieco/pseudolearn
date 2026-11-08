import { AgentError } from "../domain/agent_error.ts";
import type { Balance } from "../domain/balance.ts";
import { remainingMilli } from "../domain/balance.ts";
import { displayCredits } from "../domain/credits.ts";

const visibleDetailCodes: ReadonlySet<string> = new Set(["invalid_request", "upstream_error"]);

export function balanceHeaders(balance: Balance): Record<string, string> {
  return {
    "x-pseudolearn-credits-remaining": String(displayCredits(remainingMilli(balance))),
    "x-pseudolearn-credits-allowance": String(displayCredits(balance.allowanceMilli)),
    "x-pseudolearn-credits-top-up": String(displayCredits(balance.topUpMilli)),
    "x-pseudolearn-credits-renews-at": balance.renewsAt ?? "",
    "x-pseudolearn-credits-trial": balance.trial ? "true" : "false",
  };
}

export function asAgentError(error: unknown): AgentError {
  return error instanceof AgentError ? error : new AgentError("unexpected_failure");
}

export function errorResponse(error: AgentError, requestId: string | null): Response {
  const detail = visibleDetailCodes.has(error.code) ? error.detail : undefined;
  return Response.json(
    {
      error: {
        code: error.code,
        retryable: error.retryable,
        requestId,
        ...(detail === undefined ? {} : { detail }),
      },
    },
    { status: error.status, headers: requestId === null ? {} : { "x-request-id": requestId } },
  );
}
