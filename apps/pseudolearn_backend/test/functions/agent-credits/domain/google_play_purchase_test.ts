import { assertEquals } from "@std/assert";
import {
  type GooglePlayCatalog,
  googlePlayOneTimeOf,
  googlePlaySubscriptionEnd,
  googlePlaySubscriptionOf,
} from "../../../../supabase/functions/agent-credits/domain/google_play_purchase.ts";

const catalog: GooglePlayCatalog = {
  packageName: "com.pseudolearn.app",
  acceptsTestPurchases: false,
};
const testing: GooglePlayCatalog = { ...catalog, acceptsTestPurchases: true };
const user = "6f1c2c1e-0000-4000-8000-000000000001";

function subscription(overrides: Record<string, unknown> = {}, item: Record<string, unknown> = {}) {
  return {
    startTime: "2026-11-01T10:00:00Z",
    subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
    externalAccountIdentifiers: { obfuscatedExternalAccountId: user },
    lineItems: [{
      productId: "pseudolearn.nodo.monthly",
      expiryTime: "2026-12-01T10:00:00Z",
      latestSuccessfulOrderId: "GPA.1234-5678-9012-34567",
      offerDetails: { basePlanId: "monthly" },
      ...item,
    }],
    ...overrides,
  };
}

const topUp = {
  purchaseState: 0,
  consumptionState: 0,
  orderId: "GPA.3333-4444-5555-66666",
  obfuscatedExternalAccountId: user,
};

Deno.test("an active subscription grants its period, keyed by its order and linked by its token", () => {
  assertEquals(googlePlaySubscriptionOf("token-1", subscription(), catalog), {
    store: "google_play",
    product: "monthly",
    transactionId: "google_play:GPA.1234-5678-9012-34567",
    originalTransactionId: "token-1",
    startsAt: new Date("2026-11-01T10:00:00Z"),
    endsAt: new Date("2026-12-01T10:00:00Z"),
    trial: false,
    revoked: false,
    accountToken: user,
    customerId: null,
  });
});

Deno.test("grace periods and cancelled renewals still grant until expiry", () => {
  for (const state of ["SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "SUBSCRIPTION_STATE_CANCELED"]) {
    const granted = googlePlaySubscriptionOf(
      "t",
      subscription({ subscriptionState: state }),
      catalog,
    );
    assertEquals(granted?.product, "monthly");
  }
});

Deno.test("states without entitlement grant nothing", () => {
  for (
    const state of [
      "SUBSCRIPTION_STATE_PENDING",
      "SUBSCRIPTION_STATE_EXPIRED",
      "SUBSCRIPTION_STATE_ON_HOLD",
      "SUBSCRIPTION_STATE_PAUSED",
      "SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED",
      "SUBSCRIPTION_STATE_UNSPECIFIED",
    ]
  ) {
    assertEquals(
      googlePlaySubscriptionOf("t", subscription({ subscriptionState: state }), catalog),
      null,
    );
  }
  assertEquals(
    googlePlaySubscriptionOf("t", subscription({ subscriptionState: undefined }), catalog),
    null,
  );
});

Deno.test("a subscription without our plan, start or expiry grants nothing", () => {
  assertEquals(
    googlePlaySubscriptionOf("t", subscription({}, { productId: "other.plan" }), catalog),
    null,
  );
  assertEquals(googlePlaySubscriptionOf("t", subscription({ lineItems: [] }), catalog), null);
  assertEquals(googlePlaySubscriptionOf("t", subscription({ lineItems: "x" }), catalog), null);
  assertEquals(
    googlePlaySubscriptionOf("t", subscription({ startTime: undefined }), catalog),
    null,
  );
  assertEquals(
    googlePlaySubscriptionOf("t", subscription({}, { expiryTime: "soon" }), catalog),
    null,
  );
});

Deno.test("test purchases are granted only where the catalog accepts them", () => {
  const test = subscription({ testPurchase: {} });
  assertEquals(googlePlaySubscriptionOf("t", test, catalog), null);
  assertEquals(googlePlaySubscriptionOf("t", test, testing)?.product, "monthly");
});

Deno.test("a free trial phase marks the grant as a trial", () => {
  const trial = subscription({}, { offerPhase: { freeTrial: {} } });
  assertEquals(googlePlaySubscriptionOf("t", trial, catalog)?.trial, true);
  const paid = subscription({}, { offerPhase: { basePrice: {} } });
  assertEquals(googlePlaySubscriptionOf("t", paid, catalog)?.trial, false);
});

Deno.test("without an order the period is keyed by token and expiry", () => {
  const unordered = subscription({}, { latestSuccessfulOrderId: undefined });
  assertEquals(
    googlePlaySubscriptionOf("token-1", unordered, catalog)?.transactionId,
    "google_play:token-1:2026-12-01T10:00:00.000Z",
  );
});

Deno.test("a subscription without account identifiers has no account token", () => {
  const anonymous = subscription({ externalAccountIdentifiers: undefined });
  assertEquals(googlePlaySubscriptionOf("t", anonymous, catalog)?.accountToken, null);
});

Deno.test("the subscription end is the expiry of our plan", () => {
  assertEquals(googlePlaySubscriptionEnd(subscription()), new Date("2026-12-01T10:00:00Z"));
  assertEquals(googlePlaySubscriptionEnd({ lineItems: [] }), null);
});

Deno.test("a purchased top-up grants credits keyed by its token", () => {
  assertEquals(googlePlayOneTimeOf("token-9", "pseudolearn.nodo.topup150", topUp, catalog), {
    store: "google_play",
    product: "top_up",
    transactionId: "google_play:token-9",
    originalTransactionId: null,
    startsAt: null,
    endsAt: null,
    trial: false,
    revoked: false,
    accountToken: user,
    customerId: null,
  });
});

Deno.test("a consumed top-up is still recognised so a retry stays idempotent", () => {
  const consumed = { ...topUp, consumptionState: 1 };
  assertEquals(
    googlePlayOneTimeOf("t", "pseudolearn.nodo.topup150", consumed, catalog)?.product,
    "top_up",
  );
});

Deno.test("cancelled, pending or foreign one-time purchases grant nothing", () => {
  const id = "pseudolearn.nodo.topup150";
  assertEquals(googlePlayOneTimeOf("t", id, { ...topUp, purchaseState: 1 }, catalog), null);
  assertEquals(googlePlayOneTimeOf("t", id, { ...topUp, purchaseState: 2 }, catalog), null);
  assertEquals(googlePlayOneTimeOf("t", id, { ...topUp, purchaseState: undefined }, catalog), null);
  assertEquals(googlePlayOneTimeOf("t", "pseudolearn.nodo.monthly", topUp, catalog), null);
  assertEquals(googlePlayOneTimeOf("t", "other.product", topUp, catalog), null);
});

Deno.test("a test top-up is granted only where the catalog accepts test purchases", () => {
  const id = "pseudolearn.nodo.topup150";
  const test = { ...topUp, purchaseType: 0 };
  assertEquals(googlePlayOneTimeOf("t", id, test, catalog), null);
  assertEquals(googlePlayOneTimeOf("t", id, test, testing)?.product, "top_up");
  assertEquals(
    googlePlayOneTimeOf("t", id, { ...topUp, purchaseType: 1 }, catalog)?.product,
    "top_up",
  );
});
