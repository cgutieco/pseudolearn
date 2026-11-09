import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import {
  type CreditsDependencies,
  redeemPurchase,
} from "../../../../supabase/functions/agent-credits/application/credits_service.ts";
import {
  simulatedPurchase,
  type VerifiedPurchase,
} from "../../../../supabase/functions/agent-credits/domain/purchase.ts";
import { FakeLedger, FakeUsers } from "../../../support/agent_fakes.ts";

const claim = {
  store: "app_store",
  productId: "pseudolearn.plus.monthly",
  transactionId: "t",
  evidence: "jws",
};

function dependencies(
  purchase: VerifiedPurchase | null,
  ledger = new FakeLedger(),
): CreditsDependencies {
  return {
    users: new FakeUsers("User-1"),
    ledger,
    purchases: { verify: () => Promise.resolve(purchase) },
    checkouts: null,
    clock: { now: () => new Date("2026-11-09T12:00:00Z") },
  };
}

const storePurchase: VerifiedPurchase = {
  ...simulatedPurchase("monthly", "app_store:1"),
  store: "app_store",
  originalTransactionId: "o-1",
  accountToken: "user-1",
};

Deno.test("a purchase made for this account is applied, whatever the letter case", async () => {
  const ledger = new FakeLedger();
  await redeemPurchase("t", claim, dependencies(storePurchase, ledger));
  assertEquals([ledger.grants[0].userId, ledger.grants[0].originalTransactionId], [
    "User-1",
    "o-1",
  ]);
});

Deno.test("a purchase made for another account is refused without touching the ledger", async () => {
  const ledger = new FakeLedger();
  const foreign = { ...storePurchase, accountToken: "user-2" };
  const error = await assertRejects(
    () => redeemPurchase("t", claim, dependencies(foreign, ledger)),
    AgentError,
  );
  assertEquals([error.code, ledger.grants.length], ["purchase_owned_elsewhere", 0]);
});

Deno.test("a purchase without an account token is applied and bound by the ledger", async () => {
  const ledger = new FakeLedger();
  await redeemPurchase("t", claim, dependencies({ ...storePurchase, accountToken: null }, ledger));
  assertEquals(ledger.grants.length, 1);
});

Deno.test("a refunded purchase is revoked and reported as invalid", async () => {
  const ledger = new FakeLedger();
  const refunded = { ...storePurchase, revoked: true };
  const error = await assertRejects(
    () => redeemPurchase("t", claim, dependencies(refunded, ledger)),
    AgentError,
  );
  assertEquals([error.code, error.detail], ["invalid_request", "revoked"]);
  assertEquals(ledger.revocations[0].transactionId, "app_store:1");
  assertEquals(ledger.grants.length, 0);
});

Deno.test("an unverifiable purchase is invalid", async () => {
  const error = await assertRejects(
    () => redeemPurchase("t", claim, dependencies(null)),
    AgentError,
  );
  assertEquals(error.code, "invalid_request");
});
