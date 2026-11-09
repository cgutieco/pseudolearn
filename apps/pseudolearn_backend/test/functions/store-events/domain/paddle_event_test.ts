import { assertEquals } from "@std/assert";
import { paddleEventOf } from "../../../../supabase/functions/store-events/domain/paddle_event.ts";

const prices = { monthly: new Set(["pri_m", "pri_mt"]), topUp: "pri_t" };

function subscription(data: Record<string, unknown>, type = "subscription.updated") {
  return {
    event_type: type,
    data: {
      id: "sub_1",
      status: "active",
      customer_id: "ctm_1",
      custom_data: { user_id: "user-1" },
      items: [{ price: { id: "pri_m" } }],
      current_billing_period: {
        starts_at: "2026-11-01T00:00:00Z",
        ends_at: "2026-12-01T00:00:00Z",
      },
      ...data,
    },
  };
}

Deno.test("an active subscription becomes the period of its billing dates", () => {
  const event = paddleEventOf(subscription({}), prices);
  if (event.kind !== "purchase") throw new Error(event.kind);
  assertEquals(event.purchase.transactionId, "paddle:sub_1:2026-11-01T00:00:00.000Z");
  assertEquals([event.purchase.originalTransactionId, event.purchase.customerId], [
    "sub_1",
    "ctm_1",
  ]);
  assertEquals([event.purchase.trial, event.userHint], [false, "user-1"]);
  assertEquals(event.purchase.endsAt, new Date("2026-12-01T00:00:00Z"));
});

Deno.test("a trialing subscription is a trial period", () => {
  const event = paddleEventOf(
    subscription({ status: "trialing", items: [{ price: { id: "pri_mt" } }] }),
    prices,
  );
  assertEquals(event.kind === "purchase" && event.purchase.trial, true);
});

Deno.test("a cancellation or a pause ends the subscription at its date", () => {
  const canceled = paddleEventOf(
    subscription({ status: "canceled", canceled_at: "2026-11-20T00:00:00Z" }),
    prices,
  );
  assertEquals(canceled, {
    kind: "subscription_end",
    end: {
      store: "paddle",
      originalTransactionId: "sub_1",
      endsAt: new Date("2026-11-20T00:00:00Z"),
    },
  });
  const paused = paddleEventOf(
    subscription({ status: "paused", paused_at: "2026-11-21T00:00:00Z" }),
    prices,
  );
  assertEquals(paused.kind, "subscription_end");
  assertEquals(paddleEventOf(subscription({ status: "canceled" }), prices).kind, "ignored");
});

Deno.test("past due, foreign prices and missing periods are ignored", () => {
  assertEquals(paddleEventOf(subscription({ status: "past_due" }), prices).kind, "ignored");
  assertEquals(
    paddleEventOf(subscription({ items: [{ price: { id: "pri_other" } }] }), prices).kind,
    "ignored",
  );
  assertEquals(
    paddleEventOf(subscription({ current_billing_period: null }), prices).kind,
    "ignored",
  );
});

Deno.test("a completed top-up transaction is a top-up for the account", () => {
  const event = paddleEventOf({
    event_type: "transaction.completed",
    data: {
      id: "txn_1",
      custom_data: { user_id: "user-1" },
      items: [{ price_id: "pri_t" }],
      customer_id: "ctm_1",
    },
  }, prices);
  if (event.kind !== "purchase") throw new Error(event.kind);
  assertEquals([event.purchase.product, event.purchase.transactionId], ["top_up", "paddle:txn_1"]);
});

Deno.test("subscription transactions and other prices are not top-ups", () => {
  const renewal = { id: "txn_2", subscription_id: "sub_1", items: [{ price: { id: "pri_t" } }] };
  assertEquals(
    paddleEventOf({ event_type: "transaction.completed", data: renewal }, prices).kind,
    "ignored",
  );
  const other = { id: "txn_3", items: [{ price: { id: "pri_m" } }] };
  assertEquals(
    paddleEventOf({ event_type: "transaction.completed", data: other }, prices).kind,
    "ignored",
  );
});

Deno.test("approved refunds and chargebacks revoke their target", () => {
  const topUp = paddleEventOf({
    event_type: "adjustment.updated",
    data: { action: "refund", status: "approved", transaction_id: "txn_1" },
  }, prices);
  assertEquals(topUp, {
    kind: "revocation",
    revocation: { store: "paddle", transactionId: "paddle:txn_1", originalTransactionId: null },
  });
  const plan = paddleEventOf({
    event_type: "adjustment.created",
    data: {
      action: "chargeback",
      status: "approved",
      transaction_id: "txn_2",
      subscription_id: "sub_1",
    },
  }, prices);
  assertEquals(plan.kind === "revocation" && plan.revocation.originalTransactionId, "sub_1");
});

Deno.test("pending, credit or targetless adjustments and unknown events are ignored", () => {
  const adjustment = (data: Record<string, unknown>) =>
    paddleEventOf({ event_type: "adjustment.created", data }, prices).kind;
  assertEquals(
    adjustment({ action: "refund", status: "pending_approval", transaction_id: "t" }),
    "ignored",
  );
  assertEquals(
    adjustment({ action: "credit", status: "approved", transaction_id: "t" }),
    "ignored",
  );
  assertEquals(adjustment({ action: "refund", status: "approved" }), "ignored");
  assertEquals(paddleEventOf({ event_type: "customer.updated", data: {} }, prices).kind, "ignored");
  assertEquals(paddleEventOf({ data: {} }, prices).kind, "ignored");
  assertEquals(paddleEventOf("nope", prices).kind, "ignored");
});
