import {
  type CreditsDependencies,
  readBalance,
  redeemPurchase,
} from "../application/credits_service.ts";
import { AgentError, type AgentErrorCode } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import {
  asAgentError,
  balanceHeaders,
  errorResponse,
} from "../../agent-responses/http/agent_envelope.ts";
import { bearerTokenOf, jsonBodyOf } from "../../agent-responses/http/agent_request.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import type { PurchaseClaim } from "../domain/purchase.ts";

export type CreditsSetup =
  | { readonly kind: "ready"; readonly dependencies: CreditsDependencies }
  | { readonly kind: "unavailable"; readonly code: AgentErrorCode };

export function createCreditsHandler(setup: CreditsSetup): (request: Request) => Promise<Response> {
  return async (request) => {
    const requestId = request.headers.get("x-request-id");
    try {
      if (setup.kind === "unavailable") throw new AgentError(setup.code);
      return await route(request, setup.dependencies);
    } catch (error) {
      return errorResponse(asAgentError(error), requestId);
    }
  };
}

async function route(request: Request, dependencies: CreditsDependencies): Promise<Response> {
  const path = new URL(request.url).pathname.replace(/\/+$/, "");
  if (path.endsWith("/purchases")) {
    if (request.method !== "POST") throw new AgentError("method_not_allowed");
    const claim = claimOf(await jsonBodyOf(request));
    const { balance, repeated } = await redeemPurchase(bearerTokenOf(request), claim, dependencies);
    return balanceResponse(balance, repeated);
  }
  if (request.method !== "GET") throw new AgentError("method_not_allowed");
  return balanceResponse(await readBalance(bearerTokenOf(request), dependencies), false);
}

function claimOf(body: unknown): PurchaseClaim {
  if (!isRecord(body)) throw new AgentError("invalid_request", "body");
  const fields = [body.store, body.product_id, body.transaction_id];
  if (!fields.every((field) => typeof field === "string" && field.length > 0)) {
    throw new AgentError("invalid_request", "purchase");
  }
  return {
    store: body.store as string,
    productId: body.product_id as string,
    transactionId: body.transaction_id as string,
    evidence: typeof body.evidence === "string" ? body.evidence : "",
  };
}

function balanceResponse(balance: Balance, repeated: boolean): Response {
  return Response.json(
    {
      period_active: balance.periodActive,
      trial: balance.trial,
      trial_used: balance.trialUsed,
      renews_at: balance.renewsAt,
      repeated,
    },
    { status: 200, headers: balanceHeaders(balance) },
  );
}
