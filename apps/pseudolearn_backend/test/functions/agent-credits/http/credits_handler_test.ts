import { assertEquals } from "@std/assert";
import { createCreditsHandler } from "../../../../supabase/functions/agent-credits/http/credits_handler.ts";
import { SimulatedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/simulated_purchase_verifier.ts";
import { AllowlistedPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/allowlisted_purchase_verifier.ts";
import type { PurchaseVerifier } from "../../../../supabase/functions/agent-credits/domain/purchase.ts";
import { FakeLedger, FakeUsers } from "../../../support/agent_fakes.ts";

function setup(purchases: PurchaseVerifier | null, ledger = new FakeLedger()) {
  return {
    ledger,
    handle: createCreditsHandler({
      kind: "ready",
      dependencies: {
        users: new FakeUsers(),
        ledger,
        purchases,
        checkouts: null,
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
  const response = await handle(purchase("pseudolearn.nodo.topup150"));
  assertEquals(response.status, 403);
  assertEquals((await response.json()).error.code, "purchases_disabled");
  assertEquals(ledger.grants.length, 0);
});

Deno.test("a simulated purchase grants the catalog terms", async () => {
  const { handle, ledger } = setup(new SimulatedPurchaseVerifier());
  assertEquals((await handle(purchase("pseudolearn.nodo.monthly"))).status, 200);
  assertEquals(ledger.grants[0].product, "monthly");
  const grant = ledger.grants[0];
  const days = (grant.endsAt.getTime() - grant.startsAt.getTime()) / 86_400_000;
  assertEquals([grant.milli, days, grant.store], [300_000, 30, "simulated"]);
});

Deno.test("a repeated purchase is idempotent", async () => {
  const { handle, ledger } = setup(new SimulatedPurchaseVerifier());
  await handle(purchase("pseudolearn.nodo.topup150"));
  const second = await handle(purchase("pseudolearn.nodo.topup150"));
  assertEquals((await second.json()).repeated, true);
  assertEquals(ledger.transactions.size, 1);
});

Deno.test("the trial is keyed by account and a second trial is refused", async () => {
  const ledger = new FakeLedger();
  const { handle } = setup(new SimulatedPurchaseVerifier(), ledger);
  await handle(purchase("pseudolearn.nodo.trial", "a"));
  assertEquals(ledger.grants[0].transactionId, "trial:user-1");
  ledger.grantRefusal = "trial_used";
  assertEquals((await handle(purchase("pseudolearn.nodo.trial", "b"))).status, 409);
});

Deno.test("a top-up without an active plan answers subscription required", async () => {
  const ledger = new FakeLedger();
  const { handle } = setup(new SimulatedPurchaseVerifier(), ledger);
  ledger.grantRefusal = "subscription_required";
  const response = await handle(purchase("pseudolearn.nodo.topup150"));
  assertEquals(response.status, 402);
  assertEquals((await response.json()).error.code, "subscription_required");
  assertEquals(ledger.grants[0].product, "top_up");
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

Deno.test("an allowlisted account redeems while others get purchases disabled", async () => {
  const allowlisted = new AllowlistedPurchaseVerifier(
    new SimulatedPurchaseVerifier(),
    new Set(["user-1"]),
  );
  const { handle, ledger } = setup(allowlisted);
  assertEquals((await handle(purchase("pseudolearn.nodo.topup150"))).status, 200);
  assertEquals(ledger.grants.length, 1);
  const { handle: refuse, ledger: untouched } = setup(
    new AllowlistedPurchaseVerifier(new SimulatedPurchaseVerifier(), new Set(["someone-else"])),
  );
  const refused = await refuse(purchase("pseudolearn.nodo.topup150"));
  assertEquals(refused.status, 403);
  assertEquals((await refused.json()).error.code, "purchases_disabled");
  assertEquals(untouched.grants.length, 0);
});

Deno.test("the balance response names the store of the period", async () => {
  const { handle } = setup(null);
  const response = await handle(
    new Request("http://localhost/agent-credits", { headers: { authorization: "Bearer t" } }),
  );
  assertEquals((await response.json()).store, null);
  assertEquals(response.headers.get("x-pseudolearn-credits-store"), "");
});

Deno.test("checkout and portal answer with a link, and other methods are refused", async () => {
  const ledger = new FakeLedger();
  ledger.customers.set("paddle:user-1", "ctm_1");
  const handle = createCreditsHandler({
    kind: "ready",
    dependencies: {
      users: new FakeUsers(),
      ledger,
      purchases: null,
      checkouts: {
        open: () => Promise.resolve("https://pay.test/x"),
        portal: () => Promise.resolve("https://portal.test"),
      },
      clock: { now: () => new Date("2026-11-08T12:00:00Z") },
    },
  });
  const post = (path: string, body: unknown = {}) =>
    handle(
      new Request(`http://localhost/agent-credits/${path}`, {
        method: "POST",
        headers: { authorization: "Bearer t" },
        body: JSON.stringify(body),
      }),
    );
  const checkout = await post("checkouts", { product_id: "pseudolearn.nodo.topup150" });
  assertEquals(await checkout.json(), { url: "https://pay.test/x" });
  assertEquals(await (await post("portal")).json(), { url: "https://portal.test" });
  const unknown = await post("checkouts", { product_id: 7 });
  assertEquals((await unknown.json()).error.code, "invalid_request");
  const wrongMethod = await handle(
    new Request("http://localhost/agent-credits/portal", {
      headers: { authorization: "Bearer t" },
    }),
  );
  assertEquals(wrongMethod.status, 405);
});
