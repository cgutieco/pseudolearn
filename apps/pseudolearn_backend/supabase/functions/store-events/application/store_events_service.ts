import type { Clock } from "../../agent-responses/domain/ports.ts";
import { purchaseGrantFor } from "../../agent-credits/domain/purchase_grant.ts";
import type { VerifiedPurchase } from "../../agent-credits/domain/purchase.ts";
import type { StoreLedger } from "../../agent-credits/domain/store_ledger.ts";
import type { StoreEvent } from "../domain/store_event.ts";

export interface StoreEventsDependencies {
  readonly ledger: StoreLedger;
  readonly clock: Clock;
}

export async function handleStoreEvents(
  events: readonly StoreEvent[],
  dependencies: StoreEventsDependencies,
): Promise<string[]> {
  const outcomes: string[] = [];
  for (const event of events) outcomes.push(await handleStoreEvent(event, dependencies));
  return outcomes;
}

async function handleStoreEvent(
  event: StoreEvent,
  dependencies: StoreEventsDependencies,
): Promise<string> {
  const now = dependencies.clock.now();
  switch (event.kind) {
    case "ignored":
      return `ignored:${event.reason}`;
    case "revocation":
      return `revoked:${await dependencies.ledger.revoke({ ...event.revocation, now })}`;
    case "subscription_end":
      return `ended:${await dependencies.ledger.end(event.end)}`;
    case "purchase":
      return await applyPurchase(event.purchase, event.userHint, dependencies, now);
  }
}

async function applyPurchase(
  purchase: VerifiedPurchase,
  userHint: string | null,
  dependencies: StoreEventsDependencies,
  now: Date,
): Promise<string> {
  const owner = purchase.originalTransactionId === null
    ? null
    : await dependencies.ledger.owner(purchase.store, purchase.originalTransactionId);
  const userId = owner ?? userHint;
  if (userId === null) return "unowned";
  const outcome = await dependencies.ledger.apply(purchaseGrantFor(userId, purchase, now));
  if (outcome.kind === "refused") return `refused:${outcome.code}`;
  return outcome.repeated ? "repeated" : "applied";
}
