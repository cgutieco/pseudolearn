import { assertEquals, assertRejects } from "@std/assert";
import { PostgresStoreLedger } from "../../../../supabase/functions/agent-credits/infrastructure/postgres_store_ledger.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";

const balance = {
  period_active: false,
  trial: false,
  trial_used: false,
  allowance_milli: 0,
  period_remaining_milli: 0,
  top_up_milli: 0,
  renews_at: null,
  store: null,
};

const now = new Date("2026-11-09T12:00:00Z");

const grant = {
  userId: "u",
  store: "app_store" as const,
  product: "monthly" as const,
  transactionId: "app_store:1",
  originalTransactionId: "o-1",
  milli: 300_000,
  startsAt: now,
  endsAt: new Date("2026-12-09T18:00:00Z"),
  trial: false,
  customerId: null,
  now,
};

function ledger(reply: unknown, status = 200) {
  const fetcher = new FakeFetcher(() => Response.json(reply, { status }));
  return {
    fetcher,
    subject: new PostgresStoreLedger({
      supabaseUrl: "https://p",
      secretKey: "s",
      fetcher: fetcher.fetch,
    }),
  };
}

Deno.test("apply sends the whole grant and reports repetition", async () => {
  const { fetcher, subject } = ledger({ balance, repeated: true });
  const outcome = await subject.apply(grant);
  assertEquals(outcome.kind === "granted" && outcome.repeated, true);
  assertEquals(fetcher.requests[0].url, "https://p/rest/v1/rpc/agent_apply_purchase");
  const sent = JSON.parse(fetcher.requests[0].body);
  assertEquals([sent.p_store, sent.p_original_id, sent.p_trial], ["app_store", "o-1", false]);
  assertEquals(sent.p_ends, "2026-12-09T18:00:00.000Z");
});

Deno.test("a refused grant keeps its code and balance", async () => {
  const { subject } = ledger({ error: "purchase_owned_elsewhere", balance });
  const outcome = await subject.apply(grant);
  assertEquals(outcome.kind === "refused" ? outcome.code : null, "purchase_owned_elsewhere");
  assertEquals(outcome.balance.periodActive, false);
});

Deno.test("revoke, end, owner and customer call their functions", async () => {
  const counted = ledger(2);
  assertEquals(
    await counted.subject.revoke({
      store: "paddle",
      transactionId: null,
      originalTransactionId: "sub_1",
      now,
    }),
    2,
  );
  assertEquals(JSON.parse(counted.fetcher.requests[0].body).p_original_id, "sub_1");
  assertEquals(
    await ledger(1).subject.end({ store: "paddle", originalTransactionId: "sub_1", endsAt: now }),
    1,
  );
  assertEquals(await ledger("user-9").subject.owner("app_store", "o-1"), "user-9");
  assertEquals(await ledger("ctm_1").subject.customer("u", "paddle"), "ctm_1");
});

Deno.test("empty or unexpected replies read as nothing found", async () => {
  assertEquals(await ledger(null).subject.owner("app_store", "o-1"), null);
  assertEquals(await ledger("").subject.customer("u", "paddle"), null);
  assertEquals(
    await ledger("x").subject.end({ store: "paddle", originalTransactionId: "s", endsAt: now }),
    0,
  );
});

Deno.test("ledger failures reject", async () => {
  await assertRejects(() => ledger({}, 500).subject.apply(grant));
  await assertRejects(() => ledger({ nope: 1 }).subject.apply(grant));
});
