import {
  type AppStoreCatalog,
  appStorePurchaseOf,
} from "../../agent-credits/domain/app_store_transaction.ts";
import { ignored, type StoreEvent } from "./store_event.ts";

export function appStoreEventOf(
  transaction: Record<string, unknown> | null,
  catalog: AppStoreCatalog,
): StoreEvent {
  if (transaction === null) return ignored("no_transaction");
  const purchase = appStorePurchaseOf(transaction, catalog);
  if (purchase === null) return ignored("foreign_transaction");
  if (purchase.revoked) {
    return {
      kind: "revocation",
      revocation: {
        store: "app_store",
        transactionId: purchase.transactionId,
        originalTransactionId: null,
      },
    };
  }
  return { kind: "purchase", purchase, userHint: purchase.accountToken };
}
