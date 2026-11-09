import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { AppleSignedDataVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/apple_signed_data_verifier.ts";
import { AppStorePurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/app_store_purchase_verifier.ts";
import {
  appStoreCatalog,
  signJws,
  subscriptionTransaction,
  testNow,
  testRoot,
  topUpTransaction,
} from "../../../support/app_store_signing.ts";

const verifier = new AppStorePurchaseVerifier(
  new AppleSignedDataVerifier({ trustedRoots: [testRoot], now: () => testNow }),
  appStoreCatalog,
);

function claim(productId: string, evidence: string, store = "app_store") {
  return { store, productId, transactionId: "ignored", evidence };
}

Deno.test("a signed subscription is verified as the claimed plan", async () => {
  const jws = await signJws(subscriptionTransaction());
  const purchase = await verifier.verify(claim("pseudolearn.plus.monthly", jws));
  assertEquals([purchase?.store, purchase?.product], ["app_store", "monthly"]);
});

Deno.test("a signed top-up is verified as the claimed top-up", async () => {
  const jws = await signJws(topUpTransaction());
  assertEquals((await verifier.verify(claim("pseudolearn.plus.topup150", jws)))?.product, "top_up");
});

Deno.test("a claim that names another product than the signed one is refused", async () => {
  const jws = await signJws(topUpTransaction());
  assertEquals(await verifier.verify(claim("pseudolearn.plus.monthly", jws)), null);
});

Deno.test("claims for other stores or without evidence are not this verifier's", async () => {
  const jws = await signJws(topUpTransaction());
  assertEquals(await verifier.verify(claim("pseudolearn.plus.topup150", jws, "paddle")), null);
  assertEquals(await verifier.verify(claim("pseudolearn.plus.topup150", "")), null);
});

Deno.test("a foreign bundle is refused", async () => {
  const jws = await signJws(topUpTransaction({ bundleId: "com.other.app" }));
  assertEquals(await verifier.verify(claim("pseudolearn.plus.topup150", jws)), null);
});

Deno.test("an unverifiable signature is reported as invalid", async () => {
  const error = await assertRejects(
    () => verifier.verify(claim("pseudolearn.plus.topup150", "not-a-jws")),
    AgentError,
  );
  assertEquals([error.code, error.status], ["invalid_signature", 401]);
});
