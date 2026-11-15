import type { AgentErrorCode } from "../../agent-responses/domain/agent_error.ts";
import type { Balance } from "../../agent-responses/domain/balance.ts";
import type { PurchaseGrant } from "./purchase_grant.ts";
import type { StoreName } from "./purchase.ts";

export type PurchaseGrantOutcome =
  | { readonly kind: "granted"; readonly balance: Balance; readonly repeated: boolean }
  | { readonly kind: "refused"; readonly code: AgentErrorCode; readonly balance: Balance };

export interface PurchaseRevocation {
  readonly store: StoreName;
  readonly transactionId: string | null;
  readonly originalTransactionId: string | null;
  readonly now: Date;
}

export interface SubscriptionEnd {
  readonly store: StoreName;
  readonly originalTransactionId: string;
  readonly endsAt: Date;
}

export interface StoreLedger {
  balance(userId: string, now: Date): Promise<Balance>;
  apply(grant: PurchaseGrant): Promise<PurchaseGrantOutcome>;
  revoke(revocation: PurchaseRevocation): Promise<number>;
  end(subscription: SubscriptionEnd): Promise<number>;
  owner(store: StoreName, originalTransactionId: string): Promise<string | null>;
  customer(userId: string, store: StoreName): Promise<string | null>;
}
