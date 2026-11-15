import { assertEquals } from "@std/assert";
import { appStoreEventOf } from "../../../../supabase/functions/store-events/domain/app_store_notification.ts";
import {
  appStoreCatalog,
  subscriptionTransaction,
  testNow,
} from "../../../support/app_store_signing.ts";

Deno.test("a renewal notification applies the period for the account token", () => {
  const event = appStoreEventOf(subscriptionTransaction(), appStoreCatalog);
  if (event.kind !== "purchase") throw new Error(event.kind);
  assertEquals([event.userHint, event.purchase.originalTransactionId], ["user-1", "2000000000"]);
});

Deno.test("a refund notification revokes exactly that transaction", () => {
  const event = appStoreEventOf(
    subscriptionTransaction({ revocationDate: testNow }),
    appStoreCatalog,
  );
  assertEquals(event, {
    kind: "revocation",
    revocation: {
      store: "app_store",
      transactionId: "app_store:2000000001",
      originalTransactionId: null,
    },
  });
});

Deno.test("notifications without a transaction or for other apps are ignored", () => {
  assertEquals(appStoreEventOf(null, appStoreCatalog).kind, "ignored");
  assertEquals(
    appStoreEventOf(subscriptionTransaction({ bundleId: "x" }), appStoreCatalog).kind,
    "ignored",
  );
});
