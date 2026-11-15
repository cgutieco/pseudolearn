import { isRecord } from "../../agent-responses/domain/credits.ts";
import type { VerifiedPurchase } from "../../agent-credits/domain/purchase.ts";
import { dateOf, priceIdsOf, textOf } from "./paddle_fields.ts";
import { ignored, type StoreEvent } from "./store_event.ts";

export interface PaddlePrices {
  readonly monthly: ReadonlySet<string>;
  readonly topUp: string;
}

type Data = Record<string, unknown>;

const revokingActions: ReadonlySet<string> = new Set(["refund", "chargeback"]);
const endingStatuses: Readonly<Record<string, string>> = {
  canceled: "canceled_at",
  paused: "paused_at",
};

export function paddleEventOf(event: unknown, prices: PaddlePrices): StoreEvent {
  if (!isRecord(event) || !isRecord(event.data) || typeof event.event_type !== "string") {
    return ignored("malformed");
  }
  const type = event.event_type;
  if (type === "transaction.completed") return topUpOf(event.data, prices);
  if (type.startsWith("subscription.")) return subscriptionOf(event.data, prices);
  if (type.startsWith("adjustment.")) return adjustmentOf(event.data);
  return ignored(type);
}

function topUpOf(data: Data, prices: PaddlePrices): StoreEvent {
  const id = textOf(data.id);
  if (id === null || textOf(data.subscription_id) !== null) return ignored("not_a_top_up");
  if (!priceIdsOf(data).includes(prices.topUp)) return ignored("foreign_price");
  return purchaseEvent(data, {
    product: "top_up",
    transactionId: `paddle:${id}`,
    originalTransactionId: null,
    startsAt: null,
    endsAt: null,
    trial: false,
  });
}

function subscriptionOf(data: Data, prices: PaddlePrices): StoreEvent {
  const id = textOf(data.id);
  const status = textOf(data.status) ?? "";
  if (id === null || !priceIdsOf(data).some((price) => prices.monthly.has(price))) {
    return ignored("foreign_subscription");
  }
  const endField = endingStatuses[status];
  if (endField !== undefined) {
    const endsAt = dateOf(data[endField]);
    if (endsAt === null) return ignored("end_without_date");
    return {
      kind: "subscription_end",
      end: { store: "paddle", originalTransactionId: id, endsAt },
    };
  }
  const period = isRecord(data.current_billing_period) ? data.current_billing_period : {};
  const startsAt = dateOf(period.starts_at);
  const endsAt = dateOf(period.ends_at);
  if (!["active", "trialing"].includes(status) || startsAt === null || endsAt === null) {
    return ignored(`subscription_${status}`);
  }
  return purchaseEvent(data, {
    product: "monthly",
    transactionId: `paddle:${id}:${startsAt.toISOString()}`,
    originalTransactionId: id,
    startsAt,
    endsAt,
    trial: status === "trialing",
  });
}

function adjustmentOf(data: Data): StoreEvent {
  if (!revokingActions.has(textOf(data.action) ?? "") || data.status !== "approved") {
    return ignored("adjustment_not_revoking");
  }
  const subscriptionId = textOf(data.subscription_id);
  const transactionId = textOf(data.transaction_id);
  if (subscriptionId === null && transactionId === null) {
    return ignored("adjustment_without_target");
  }
  return {
    kind: "revocation",
    revocation: {
      store: "paddle",
      transactionId: subscriptionId === null ? `paddle:${transactionId}` : null,
      originalTransactionId: subscriptionId,
    },
  };
}

type PurchaseFields = Pick<
  VerifiedPurchase,
  "product" | "transactionId" | "originalTransactionId" | "startsAt" | "endsAt" | "trial"
>;

function purchaseEvent(data: Data, fields: PurchaseFields): StoreEvent {
  const custom = isRecord(data.custom_data) ? data.custom_data : {};
  const purchase: VerifiedPurchase = {
    ...fields,
    store: "paddle",
    revoked: false,
    accountToken: null,
    customerId: textOf(data.customer_id),
  };
  return { kind: "purchase", purchase, userHint: textOf(custom.user_id) };
}
