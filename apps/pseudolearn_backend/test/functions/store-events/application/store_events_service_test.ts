import { assertEquals } from "@std/assert";
import { simulatedPurchase } from "../../../../supabase/functions/agent-credits/domain/purchase.ts";
import { handleStoreEvents } from "../../../../supabase/functions/store-events/application/store_events_service.ts";
import type { StoreEvent } from "../../../../supabase/functions/store-events/domain/store_event.ts";
import { FakeLedger } from "../../../support/agent_fakes.ts";

const now = new Date("2026-11-09T12:00:00Z");
const renewal = {
  ...simulatedPurchase("monthly", "paddle:sub_1:x"),
  store: "paddle" as const,
  originalTransactionId: "sub_1",
};

function run(events: StoreEvent[], ledger = new FakeLedger()) {
  return handleStoreEvents(events, { ledger, clock: { now: () => now } });
}

Deno.test("a purchase goes to the linked owner before the hint", async () => {
  const ledger = new FakeLedger();
  ledger.owners.set("paddle:sub_1", "owner");
  assertEquals(await run([{ kind: "purchase", purchase: renewal, userHint: "hint" }], ledger), [
    "applied",
  ]);
  assertEquals(ledger.grants[0].userId, "owner");
});

Deno.test("without a link the hint names the account, and without either nothing happens", async () => {
  const ledger = new FakeLedger();
  await run([{ kind: "purchase", purchase: renewal, userHint: "hint" }], ledger);
  assertEquals(ledger.grants[0].userId, "hint");
  assertEquals(await run([{ kind: "purchase", purchase: renewal, userHint: null }]), ["unowned"]);
});

Deno.test("refusals and repetitions are reported, not thrown", async () => {
  const ledger = new FakeLedger();
  const topUp = {
    kind: "purchase" as const,
    purchase: simulatedPurchase("top_up", "t"),
    userHint: "u",
  };
  assertEquals(await run([topUp, topUp], ledger), ["applied", "repeated"]);
  ledger.grantRefusal = "subscription_required";
  assertEquals(await run([topUp], ledger), ["refused:subscription_required"]);
});

Deno.test("revocations, ends and ignored events reach the ledger in order", async () => {
  const ledger = new FakeLedger();
  const outcomes = await run([
    {
      kind: "revocation",
      revocation: { store: "paddle", transactionId: null, originalTransactionId: "sub_1" },
    },
    {
      kind: "subscription_end",
      end: { store: "paddle", originalTransactionId: "sub_1", endsAt: now },
    },
    { kind: "ignored", reason: "customer.updated" },
  ], ledger);
  assertEquals(outcomes, ["revoked:1", "ended:1", "ignored:customer.updated"]);
  assertEquals(ledger.revocations[0].now, now);
});

Deno.test("an empty batch does nothing", async () => {
  assertEquals(await run([]), []);
});
