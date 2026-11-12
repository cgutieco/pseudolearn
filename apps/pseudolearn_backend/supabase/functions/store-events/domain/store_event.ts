import type { VerifiedPurchase } from "../../agent-credits/domain/purchase.ts";
import type {
  PurchaseRevocation,
  SubscriptionEnd,
} from "../../agent-credits/domain/store_ledger.ts";

export type StoreEvent =
  | {
    readonly kind: "purchase";
    readonly purchase: VerifiedPurchase;
    readonly userHint: string | null;
  }
  | { readonly kind: "revocation"; readonly revocation: Omit<PurchaseRevocation, "now"> }
  | { readonly kind: "subscription_end"; readonly end: SubscriptionEnd }
  | { readonly kind: "ignored"; readonly reason: string };

export interface StoreEventReader {
  read(body: string, signature: string | null): Promise<readonly StoreEvent[]>;
}

export function ignored(reason: string): StoreEvent {
  return { kind: "ignored", reason };
}
