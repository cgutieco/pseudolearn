import { assertEquals } from "@std/assert";
import { appStorePurchaseOf } from "../../../../supabase/functions/agent-credits/domain/app_store_transaction.ts";
import {
  appStoreCatalog,
  subscriptionTransaction,
  testNow,
  topUpTransaction,
} from "../../../support/app_store_signing.ts";

Deno.test("a subscription transaction keeps its chain and store dates", () => {
  const purchase = appStorePurchaseOf(subscriptionTransaction(), appStoreCatalog);
  assertEquals(purchase?.product, "monthly");
  assertEquals(purchase?.transactionId, "app_store:2000000001");
  assertEquals(purchase?.originalTransactionId, "2000000000");
  assertEquals(purchase?.endsAt?.getTime(), testNow + 29 * 86_400_000);
  assertEquals([purchase?.trial, purchase?.revoked, purchase?.accountToken], [
    false,
    false,
    "user-1",
  ]);
});

Deno.test("a top-up has no chain and no dates", () => {
  const purchase = appStorePurchaseOf(topUpTransaction(), appStoreCatalog);
  assertEquals([purchase?.product, purchase?.originalTransactionId], ["top_up", null]);
  assertEquals([purchase?.startsAt, purchase?.endsAt], [null, null]);
});

Deno.test("the introductory free offer is a trial and a paid offer is not", () => {
  const trial = subscriptionTransaction({ offerType: 1, offerDiscountType: "FREE_TRIAL" });
  assertEquals(appStorePurchaseOf(trial, appStoreCatalog)?.trial, true);
  const legacyTrial = subscriptionTransaction({ offerType: 1 });
  assertEquals(appStorePurchaseOf(legacyTrial, appStoreCatalog)?.trial, true);
  const discounted = subscriptionTransaction({ offerType: 1, offerDiscountType: "PAY_AS_YOU_GO" });
  assertEquals(appStorePurchaseOf(discounted, appStoreCatalog)?.trial, false);
  const promotional = subscriptionTransaction({ offerType: 2 });
  assertEquals(appStorePurchaseOf(promotional, appStoreCatalog)?.trial, false);
});

Deno.test("a refunded transaction is marked as revoked", () => {
  const refunded = subscriptionTransaction({ revocationDate: testNow });
  assertEquals(appStorePurchaseOf(refunded, appStoreCatalog)?.revoked, true);
});

Deno.test("foreign or incomplete transactions are rejected", () => {
  const rejected = [
    subscriptionTransaction({ bundleId: "com.other.app" }),
    subscriptionTransaction({ environment: "Xcode" }),
    subscriptionTransaction({ productId: "pseudolearn.plus.trial" }),
    subscriptionTransaction({ productId: "com.other.product" }),
    subscriptionTransaction({ expiresDate: undefined }),
    subscriptionTransaction({ transactionId: "" }),
    subscriptionTransaction({ purchaseDate: "yesterday" }),
  ];
  for (const payload of rejected) assertEquals(appStorePurchaseOf(payload, appStoreCatalog), null);
});

Deno.test("a missing account token is kept as unknown", () => {
  const anonymous = topUpTransaction({ appAccountToken: undefined });
  assertEquals(appStorePurchaseOf(anonymous, appStoreCatalog)?.accountToken, null);
});
