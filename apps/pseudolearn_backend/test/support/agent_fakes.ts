import type { AgentDependencies } from "../../supabase/functions/agent-responses/application/agent_service.ts";
import type { AgentErrorCode } from "../../supabase/functions/agent-responses/domain/agent_error.ts";
import {
  type Balance,
  emptyBalance,
} from "../../supabase/functions/agent-responses/domain/balance.ts";
import type {
  Authorization,
  LedgerCall,
  LedgerGateway,
  ModelGateway,
  ModelReply,
  UserVerifier,
} from "../../supabase/functions/agent-responses/domain/ports.ts";
import type { PurchaseGrant } from "../../supabase/functions/agent-credits/domain/purchase_grant.ts";
import type { StoreName } from "../../supabase/functions/agent-credits/domain/purchase.ts";
import type {
  PurchaseGrantOutcome,
  PurchaseRevocation,
  StoreLedger,
  SubscriptionEnd,
} from "../../supabase/functions/agent-credits/domain/store_ledger.ts";

export const activeBalance: Balance = {
  ...emptyBalance,
  periodActive: true,
  allowanceMilli: 300_000,
  periodRemainingMilli: 120_400,
  topUpMilli: 150_000,
  renewsAt: "2026-12-08T00:00:00.000Z",
};

export class FakeUsers implements UserVerifier {
  constructor(public userId: string | null = "user-1") {}

  verify(): Promise<string | null> {
    return Promise.resolve(this.userId);
  }
}

export class FakeLedger implements LedgerGateway, StoreLedger {
  refusal: AgentErrorCode | null = null;
  grantRefusal: AgentErrorCode | null = null;
  readonly debits: { call: LedgerCall; milli: number }[] = [];
  readonly grants: PurchaseGrant[] = [];
  readonly transactions = new Set<string>();
  readonly revocations: PurchaseRevocation[] = [];
  readonly ends: SubscriptionEnd[] = [];
  readonly owners = new Map<string, string>();
  readonly customers = new Map<string, string>();
  currentBalance: Balance = activeBalance;

  authorize(): Promise<Authorization> {
    return Promise.resolve(
      this.refusal === null
        ? { kind: "authorized", balance: activeBalance }
        : { kind: "refused", code: this.refusal, balance: emptyBalance },
    );
  }

  debit(call: LedgerCall, milli: number): Promise<Balance> {
    this.debits.push({ call, milli });
    return Promise.resolve(activeBalance);
  }

  balance(): Promise<Balance> {
    return Promise.resolve(this.currentBalance);
  }

  apply(grant: PurchaseGrant): Promise<PurchaseGrantOutcome> {
    this.grants.push(grant);
    if (this.grantRefusal !== null) {
      return Promise.resolve({ kind: "refused", code: this.grantRefusal, balance: activeBalance });
    }
    const repeated = this.transactions.has(grant.transactionId);
    this.transactions.add(grant.transactionId);
    return Promise.resolve({ kind: "granted", balance: activeBalance, repeated });
  }

  revoke(revocation: PurchaseRevocation): Promise<number> {
    this.revocations.push(revocation);
    return Promise.resolve(1);
  }

  end(subscription: SubscriptionEnd): Promise<number> {
    this.ends.push(subscription);
    return Promise.resolve(1);
  }

  owner(store: StoreName, originalTransactionId: string): Promise<string | null> {
    return Promise.resolve(this.owners.get(`${store}:${originalTransactionId}`) ?? null);
  }

  customer(userId: string, store: StoreName): Promise<string | null> {
    return Promise.resolve(this.customers.get(`${store}:${userId}`) ?? null);
  }
}

export const usageBody = {
  output: [],
  usage: {
    input_tokens: 10_000,
    input_tokens_details: { cached_tokens: 2_000 },
    output_tokens: 400,
  },
};

export class FakeModel implements ModelGateway {
  readonly bodies: Record<string, unknown>[] = [];

  constructor(public reply: ModelReply = okReply(usageBody)) {}

  respond(body: Record<string, unknown>): Promise<ModelReply> {
    this.bodies.push(body);
    return Promise.resolve(this.reply);
  }
}

export function okReply(json: unknown, status = 200): ModelReply {
  return { status, body: JSON.stringify(json), json, retryAfter: null };
}

export function agentDependencies(
  overrides: Partial<AgentDependencies> = {},
): AgentDependencies {
  return {
    users: new FakeUsers(),
    ledger: new FakeLedger(),
    model: new FakeModel(),
    policy: { model: "gpt-6-luna" },
    clock: { now: () => new Date("2026-11-08T12:00:00Z") },
    ...overrides,
  };
}

export const validBody = {
  instructions: "Eres Nodo.",
  input: [{ role: "user", content: "Hola" }],
  tools: [{ type: "function", name: "check_program", parameters: {} }],
};

export function agentRequest(
  body: unknown = validBody,
  headers: Record<string, string> = {},
  method = "POST",
): Request {
  return new Request("http://localhost/agent-responses", {
    method,
    headers: {
      authorization: "Bearer token",
      "x-request-id": "req-1",
      "x-pseudolearn-turn-id": "turn-1",
      ...headers,
    },
    body: method === "GET" ? undefined : typeof body === "string" ? body : JSON.stringify(body),
  });
}
