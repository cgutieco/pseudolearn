import { assertEquals } from "@std/assert";
import { purchaseGrantFor } from "../../../../supabase/functions/agent-credits/domain/purchase_grant.ts";
import {
  simulatedPurchase,
  type VerifiedPurchase,
} from "../../../../supabase/functions/agent-credits/domain/purchase.ts";

const now = new Date("2026-11-09T12:00:00Z");
const day = 86_400_000;

const storePeriod: VerifiedPurchase = {
  ...simulatedPurchase("monthly", "app_store:1"),
  store: "app_store",
  originalTransactionId: "o-1",
  startsAt: new Date("2026-11-01T00:00:00Z"),
  endsAt: new Date("2026-12-01T00:00:00Z"),
};

Deno.test("a simulated plan lasts the catalog days from now", () => {
  const grant = purchaseGrantFor("u", simulatedPurchase("monthly", "simulated:1"), now);
  assertEquals(grant.startsAt, now);
  assertEquals(grant.endsAt.getTime() - now.getTime(), 30 * day);
  assertEquals(grant.milli, 300_000);
});

Deno.test("a store period keeps the store dates plus the renewal grace", () => {
  const grant = purchaseGrantFor("u", storePeriod, now);
  assertEquals(grant.startsAt, storePeriod.startsAt);
  assertEquals(grant.endsAt, new Date("2026-12-01T06:00:00Z"));
  assertEquals([grant.store, grant.originalTransactionId], ["app_store", "o-1"]);
});

Deno.test("a store trial grants the trial credits, not the plan", () => {
  assertEquals(purchaseGrantFor("u", { ...storePeriod, trial: true }, now).milli, 40_000);
  assertEquals(purchaseGrantFor("u", simulatedPurchase("trial", "trial:u"), now).milli, 40_000);
});

Deno.test("a top-up has no length and grants its credits", () => {
  const grant = purchaseGrantFor("u", simulatedPurchase("top_up", "simulated:t"), now);
  assertEquals([grant.milli, grant.startsAt, grant.endsAt], [150_000, now, now]);
});
