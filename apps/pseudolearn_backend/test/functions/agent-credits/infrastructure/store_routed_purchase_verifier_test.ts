import { assertEquals } from "@std/assert";
import { SimulatedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/simulated_purchase_verifier.ts";
import { StoreRoutedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/store_routed_purchase_verifier.ts";

const routed = new StoreRoutedPurchaseVerifier(
  new Map([["simulated", new SimulatedPurchaseVerifier()]]),
);

Deno.test("a claim goes to the verifier of its store", async () => {
  const claim = {
    store: "simulated",
    productId: "pseudolearn.nodo.monthly",
    transactionId: "t",
    evidence: "",
  };
  assertEquals((await routed.verify(claim, "u"))?.transactionId, "simulated:t");
});

Deno.test("a store without a verifier verifies nothing", async () => {
  const claim = {
    store: "app_store",
    productId: "pseudolearn.nodo.monthly",
    transactionId: "t",
    evidence: "x",
  };
  assertEquals(await routed.verify(claim, "u"), null);
  assertEquals(await new StoreRoutedPurchaseVerifier(new Map()).verify(claim, "u"), null);
});
