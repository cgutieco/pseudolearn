import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { AllowlistedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/allowlisted_purchase_verifier.ts";
import { SimulatedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/simulated_purchase_verifier.ts";
import { simulatedPurchase } from "../../../../supabase/functions/agent-credits/domain/purchase.ts";

const claim = {
  store: "simulated",
  productId: "pseudolearn.plus.topup150",
  transactionId: "tx-1",
  evidence: "",
};

function verifierFor(users: string[]) {
  return new AllowlistedPurchaseVerifier(new SimulatedPurchaseVerifier(), new Set(users));
}

Deno.test("an allowlisted account gets the simulated verification", async () => {
  const verified = await verifierFor(["user-1"]).verify(claim, "user-1");
  assertEquals(verified, simulatedPurchase("top_up", "simulated:tx-1"));
});

Deno.test("an account outside the allowlist is refused as purchases disabled", async () => {
  const error = await assertRejects(
    () => verifierFor(["user-1"]).verify(claim, "user-2"),
    AgentError,
  );
  assertEquals(error.code, "purchases_disabled");
});

Deno.test("an empty allowlist refuses every account", async () => {
  await assertRejects(() => verifierFor([]).verify(claim, "user-1"), AgentError);
});

Deno.test("an allowlisted account still gets invalid claims rejected", async () => {
  const verified = await verifierFor(["user-1"]).verify(
    { ...claim, store: "app_store" },
    "user-1",
  );
  assertEquals(verified, null);
});
