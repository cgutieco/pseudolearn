import { assertEquals } from "@std/assert";
import { createCreditsHandler } from "../../../../supabase/functions/agent-credits/http/credits_handler.ts";
import { SimulatedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/simulated_purchase_verifier.ts";
import { FakeLedger, FakeUsers } from "../../../support/agent_fakes.ts";

function setup(purchases: SimulatedPurchaseVerifier | null, ledger = new FakeLedger()) {
  return {
    ledger,
    handle: createCreditsHandler({
      kind: "ready",
      dependencies: {
        users: new FakeUsers(),
        ledger,
        purchases,
        clock: { now: () => new Date("2026-11-08T12:00:00Z") },
      },
    }),
  };
}

function purchase(productId: string, transactionId = "tx-1"): Request {
  return new Request("http://localhost/agent-credits/purchases", {
    method: "POST",
    headers: { authorization: "Bearer t" },
    body: JSON.stringify({
      store: "simulated",
      product_id: productId,
      transaction_id: transactionId,
    }),
  });
}

Deno.test("GET returns the balance in headers", async () => {
  const { handle } = setup(null);
  const response = await handle(
    new Request("http://localhost/agent-credits", { headers: { authorization: "Bearer t" } }),
  );
  assertEquals(response.status, 200);
  assertEquals(response.headers.get("x-pseudolearn-credits-allowance"), "300");
});

Deno.test("purchases are refused when the adapter is disabled", async () => {
  const { handle, ledger } = setup(null);
  const response = await handle(purchase("pseudolearn.plus.topup150"));
  assertEquals(response.status, 403);
  assertEquals((await response.json()).error.code, "purchases_disabled");
  assertEquals(ledger.grants.length, 0);
});

Deno.test("a simulated purchase grants the catalog terms", async () => {
  const { handle, ledger } = setup(new SimulatedPurchaseVerifier());
  assertEquals((await handle(purchase("pseudolearn.plus.monthly"))).status, 200);
  assertEquals(ledger.grants[0].product, "monthly");
  assertEquals([ledger.grants[0].milli, ledger.grants[0].days], [300_000, 30]);
});

Deno.test("a repeated purchase is idempotent", async () => {
  const { handle, ledger } = setup(new SimulatedPurchaseVerifier());
  await handle(purchase("pseudolearn.plus.topup150"));
  const second = await handle(purchase("pseudolearn.plus.topup150"));
  assertEquals((await second.json()).repeated, true);
  assertEquals(ledger.transactions.size, 1);
});

Deno.test("the trial is keyed by account and a second trial is refused", async () => {
  const ledger = new FakeLedger();
  const { handle } = setup(new SimulatedPurchaseVerifier(), ledger);
  await handle(purchase("pseudolearn.plus.trial", "a"));
  assertEquals(ledger.grants[0].transactionId, "trial:user-1");
  ledger.grantRefusal = "trial_used";
  assertEquals((await handle(purchase("pseudolearn.plus.trial", "b"))).status, 409);
});

Deno.test("unknown products and malformed bodies are invalid", async () => {
  const { handle } = setup(new SimulatedPurchaseVerifier());
  assertEquals((await handle(purchase("com.other.app"))).status, 422);
  const malformed = new Request("http://localhost/agent-credits/purchases", {
    method: "POST",
    headers: { authorization: "Bearer t" },
    body: JSON.stringify({ store: "simulated" }),
  });
  assertEquals((await handle(malformed)).status, 422);
});

Deno.test("wrong methods and a missing environment are reported", async () => {
  const { handle } = setup(null);
  const wrong = new Request("http://localhost/agent-credits/purchases", {
    method: "GET",
    headers: { authorization: "Bearer t" },
  });
  assertEquals((await handle(wrong)).status, 405);
  const unavailable = createCreditsHandler({ kind: "unavailable", code: "misconfigured" });
  assertEquals((await unavailable(new Request("http://localhost/agent-credits"))).status, 500);
});
