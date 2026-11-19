import { assertEquals } from "@std/assert";
import {
  googlePlayNoticeOf,
  googlePlaySubscriptionEventOf,
} from "../../../../supabase/functions/store-events/domain/google_play_notification.ts";

const packageName = "com.pseudolearn.app";
const catalog = { packageName, acceptsTestPurchases: false };
const user = "6f1c2c1e-0000-4000-8000-000000000001";

function notification(fields: Record<string, unknown>) {
  return { version: "1.0", packageName, eventTimeMillis: "1800000000000", ...fields };
}

function plan(state: string, expiryTime = "2026-12-01T00:00:00Z") {
  return {
    startTime: "2026-11-01T00:00:00Z",
    subscriptionState: state,
    externalAccountIdentifiers: { obfuscatedExternalAccountId: user },
    lineItems: [{
      productId: "pseudolearn.nodo.monthly",
      expiryTime,
      latestSuccessfulOrderId: "GPA.1",
    }],
  };
}

Deno.test("one-time product notifications are read as one-time notices", () => {
  const notice = googlePlayNoticeOf(
    notification({
      oneTimeProductNotification: {
        notificationType: 2,
        purchaseToken: "t",
        sku: "pseudolearn.nodo.topup150",
      },
    }),
    packageName,
  );
  assertEquals(notice, {
    kind: "one_time",
    token: "t",
    productId: "pseudolearn.nodo.topup150",
    cancelled: true,
  });
});

Deno.test("subscription notifications ask for the current state, except revocations", () => {
  for (const notificationType of [1, 2, 3, 4, 5, 6, 7, 10, 13, 17, 18]) {
    assertEquals(
      googlePlayNoticeOf(
        notification({ subscriptionNotification: { notificationType, purchaseToken: "t" } }),
        packageName,
      ),
      { kind: "subscription", token: "t" },
    );
  }
  assertEquals(
    googlePlayNoticeOf(
      notification({ subscriptionNotification: { notificationType: 12, purchaseToken: "t" } }),
      packageName,
    ),
    { kind: "subscription_revoked", token: "t" },
  );
});

Deno.test("a cancelled pending subscription and a subscription without token are ignored", () => {
  const pending = { subscriptionNotification: { notificationType: 20, purchaseToken: "t" } };
  assertEquals(googlePlayNoticeOf(notification(pending), packageName), {
    kind: "ignored",
    reason: "pending_purchase_canceled",
  });
  const tokenless = { subscriptionNotification: { notificationType: 4 } };
  assertEquals(googlePlayNoticeOf(notification(tokenless), packageName).kind, "ignored");
});

Deno.test("voided purchases tell subscriptions from one-time products", () => {
  const voided = (productType: number) =>
    notification({
      voidedPurchaseNotification: {
        purchaseToken: "t",
        orderId: "GPA.1",
        productType,
        refundType: 1,
      },
    });
  assertEquals(googlePlayNoticeOf(voided(1), packageName), {
    kind: "voided",
    token: "t",
    subscription: true,
  });
  assertEquals(googlePlayNoticeOf(voided(2), packageName), {
    kind: "voided",
    token: "t",
    subscription: false,
  });
  const tokenless = notification({ voidedPurchaseNotification: { productType: 1 } });
  assertEquals(googlePlayNoticeOf(tokenless, packageName).kind, "ignored");
});

Deno.test("tests, other packages, unknown kinds and malformed bodies are ignored", () => {
  const reasons = [
    googlePlayNoticeOf(notification({ testNotification: { version: "1.0" } }), packageName),
    googlePlayNoticeOf({ ...notification({}), packageName: "com.other.app" }, packageName),
    googlePlayNoticeOf(notification({ pendingRefundReviewNotification: {} }), packageName),
    googlePlayNoticeOf("text", packageName),
    googlePlayNoticeOf(null, packageName),
  ].map((notice) => notice.kind === "ignored" ? notice.reason : notice.kind);
  assertEquals(reasons, [
    "test",
    "foreign_package",
    "unsupported_notification",
    "malformed",
    "malformed",
  ]);
});

Deno.test("an entitled subscription becomes a purchase attributed to its account", () => {
  const event = googlePlaySubscriptionEventOf("t", plan("SUBSCRIPTION_STATE_ACTIVE"), catalog);
  assertEquals(event.kind, "purchase");
  if (event.kind !== "purchase") return;
  assertEquals(event.userHint, user);
  assertEquals(event.purchase.transactionId, "google_play:GPA.1");
});

Deno.test("expired, held or paused subscriptions end at their expiry", () => {
  for (
    const state of [
      "SUBSCRIPTION_STATE_EXPIRED",
      "SUBSCRIPTION_STATE_ON_HOLD",
      "SUBSCRIPTION_STATE_PAUSED",
    ]
  ) {
    assertEquals(googlePlaySubscriptionEventOf("t", plan(state), catalog), {
      kind: "subscription_end",
      end: {
        store: "google_play",
        originalTransactionId: "t",
        endsAt: new Date("2026-12-01T00:00:00Z"),
      },
    });
  }
  assertEquals(
    googlePlaySubscriptionEventOf("t", plan("SUBSCRIPTION_STATE_EXPIRED", "never"), catalog),
    { kind: "ignored", reason: "end_without_date" },
  );
});

Deno.test("unknown tokens and pending subscriptions are ignored", () => {
  assertEquals(googlePlaySubscriptionEventOf("t", null, catalog), {
    kind: "ignored",
    reason: "unknown_purchase",
  });
  assertEquals(googlePlaySubscriptionEventOf("t", plan("SUBSCRIPTION_STATE_PENDING"), catalog), {
    kind: "ignored",
    reason: "subscription_subscription_state_pending",
  });
});
