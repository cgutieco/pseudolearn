import { googlePlayOneTimeTransactionId } from "../../agent-credits/domain/google_play_purchase.ts";
import type { StoreEvent } from "./store_event.ts";

export function googlePlayRevocationOf(token: string, subscription: boolean): StoreEvent {
  return {
    kind: "revocation",
    revocation: {
      store: "google_play",
      transactionId: subscription ? null : googlePlayOneTimeTransactionId(token),
      originalTransactionId: subscription ? token : null,
    },
  };
}
