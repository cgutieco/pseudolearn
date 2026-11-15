import type { AgentErrorCode } from "../../agent-responses/domain/agent_error.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import {
  ledgerBalanceOf,
  PostgresLedger,
} from "../../agent-responses/infrastructure/postgres_ledger.ts";
import { callRpc } from "../../agent-responses/infrastructure/supabase_rpc.ts";
import type { SupabaseEndpoint } from "../../agent-responses/infrastructure/supabase_user_verifier.ts";
import type { PurchaseGrant } from "../domain/purchase_grant.ts";
import type { StoreName } from "../domain/purchase.ts";
import type {
  PurchaseGrantOutcome,
  PurchaseRevocation,
  StoreLedger,
  SubscriptionEnd,
} from "../domain/store_ledger.ts";

export class PostgresStoreLedger implements StoreLedger {
  private readonly ledger: PostgresLedger;

  constructor(private readonly endpoint: SupabaseEndpoint) {
    this.ledger = new PostgresLedger(endpoint);
  }

  balance(userId: string, now: Date): Promise<Balance> {
    return this.ledger.balance(userId, now);
  }

  async apply(grant: PurchaseGrant): Promise<PurchaseGrantOutcome> {
    const reply = await callRpc(this.endpoint, "agent_apply_purchase", {
      p_user: grant.userId,
      p_store: grant.store,
      p_product: grant.product,
      p_transaction_id: grant.transactionId,
      p_original_id: grant.originalTransactionId,
      p_milli: grant.milli,
      p_starts: grant.startsAt.toISOString(),
      p_ends: grant.endsAt.toISOString(),
      p_trial: grant.trial,
      p_customer: grant.customerId,
      p_now: grant.now.toISOString(),
    });
    const balance = ledgerBalanceOf(isRecord(reply) ? reply.balance : null);
    const error = isRecord(reply) ? reply.error : undefined;
    if (typeof error === "string") {
      return { kind: "refused", code: error as AgentErrorCode, balance };
    }
    return { kind: "granted", balance, repeated: isRecord(reply) && reply.repeated === true };
  }

  async revoke(revocation: PurchaseRevocation): Promise<number> {
    return countOf(
      await callRpc(this.endpoint, "agent_revoke_purchase", {
        p_store: revocation.store,
        p_transaction_id: revocation.transactionId,
        p_original_id: revocation.originalTransactionId,
        p_now: revocation.now.toISOString(),
      }),
    );
  }

  async end(subscription: SubscriptionEnd): Promise<number> {
    return countOf(
      await callRpc(this.endpoint, "agent_end_subscription", {
        p_store: subscription.store,
        p_original_id: subscription.originalTransactionId,
        p_ends: subscription.endsAt.toISOString(),
      }),
    );
  }

  async owner(store: StoreName, originalTransactionId: string): Promise<string | null> {
    return textOf(
      await callRpc(this.endpoint, "agent_store_owner", {
        p_store: store,
        p_original_id: originalTransactionId,
      }),
    );
  }

  async customer(userId: string, store: StoreName): Promise<string | null> {
    return textOf(
      await callRpc(this.endpoint, "agent_store_customer", { p_user: userId, p_store: store }),
    );
  }
}

function countOf(reply: unknown): number {
  return typeof reply === "number" ? reply : 0;
}

function textOf(reply: unknown): string | null {
  return typeof reply === "string" && reply.length > 0 ? reply : null;
}
