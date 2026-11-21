import { assertEquals } from "@std/assert";
import {
  googlePlayOneTimeEventOf,
  oneTimeNoticeOf,
} from "../../../../supabase/functions/store-events/domain/google_play_one_time_notification.ts";

const catalog = { packageName: "com.pseudolearn.app", acceptsTestPurchases: false };
const user = "6f1c2c1e-0000-4000-8000-000000000001";
const sku = "pseudolearn.nodo.topup150";

Deno.test("purchased and cancelled one-time notifications carry their token and sku", () => {
  assertEquals(oneTimeNoticeOf({ notificationType: 1, purchaseToken: "t", sku }), {
    kind: "one_time",
    token: "t",
    productId: sku,
    cancelled: false,
  });
  assertEquals(oneTimeNoticeOf({ notificationType: 2, purchaseToken: "t", sku }), {
    kind: "one_time",
    token: "t",
    productId: sku,
    cancelled: true,
  });
});

Deno.test("incomplete or unknown one-time notifications are ignored", () => {
  assertEquals(oneTimeNoticeOf({ notificationType: 1, purchaseToken: "t" }), {
    kind: "ignored",
    reason: "one_time_incomplete",
  });
  assertEquals(oneTimeNoticeOf({ notificationType: 1, sku }), {
    kind: "ignored",
    reason: "one_time_incomplete",
  });
  assertEquals(oneTimeNoticeOf({ notificationType: 3, purchaseToken: "t", sku }), {
    kind: "ignored",
    reason: "one_time_unknown_type",
  });
});

Deno.test("a purchased top-up becomes a purchase attributed to its account", () => {
  const event = googlePlayOneTimeEventOf(
    { kind: "one_time", token: "t", productId: sku, cancelled: false },
    { purchaseState: 0, obfuscatedExternalAccountId: user },
    catalog,
  );
  assertEquals(event.kind === "purchase" ? event.userHint : null, user);
});

Deno.test("a purchase that is not granted or not known is ignored", () => {
  const notice = { kind: "one_time" as const, token: "t", productId: sku, cancelled: false };
  assertEquals(googlePlayOneTimeEventOf(notice, null, catalog), {
    kind: "ignored",
    reason: "unknown_purchase",
  });
  assertEquals(googlePlayOneTimeEventOf(notice, { purchaseState: 1 }, catalog), {
    kind: "ignored",
    reason: "one_time_not_granted",
  });
});

Deno.test("a revoked top-up is revoked by its token", () => {
  const notice = { kind: "one_time" as const, token: "t", productId: sku, cancelled: true };
  assertEquals(googlePlayOneTimeEventOf(notice, { purchaseState: 1 }, catalog), {
    kind: "revocation",
    revocation: {
      store: "google_play",
      transactionId: "google_play:t",
      originalTransactionId: null,
    },
  });
});

Deno.test("a cancelled pending purchase that is not cancelled in Google revokes nothing", () => {
  const notice = { kind: "one_time" as const, token: "t", productId: sku, cancelled: true };
  for (const purchaseState of [0, 2, undefined]) {
    assertEquals(googlePlayOneTimeEventOf(notice, { purchaseState }, catalog), {
      kind: "ignored",
      reason: "one_time_not_cancelled",
    });
  }
  assertEquals(googlePlayOneTimeEventOf(notice, null, catalog), {
    kind: "ignored",
    reason: "unknown_purchase",
  });
});
