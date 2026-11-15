import { assertEquals, assertRejects } from "@std/assert";
import { PostgresLedger } from "../../../../supabase/functions/agent-responses/infrastructure/postgres_ledger.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";

const balance = {
  period_active: true,
  trial: true,
  trial_used: true,
  allowance_milli: 40_000,
  period_remaining_milli: 39_000,
  top_up_milli: 0,
  renews_at: "2026-11-15T12:00:00Z",
};

const call = { userId: "u", requestId: "r", turnId: "t", now: new Date("2026-11-08T12:00:00Z") };

function ledger(reply: unknown, status = 200) {
  const fetcher = new FakeFetcher(() => Response.json(reply, { status }));
  return {
    fetcher,
    ledger: new PostgresLedger({
      supabaseUrl: "https://p",
      secretKey: "s",
      fetcher: fetcher.fetch,
    }),
  };
}

Deno.test("authorize sends the cap and rate and reads the balance", async () => {
  const { fetcher, ledger: subject } = ledger({ balance });
  const outcome = await subject.authorize(call);
  assertEquals(outcome.kind, "authorized");
  assertEquals(fetcher.requests[0].url, "https://p/rest/v1/rpc/agent_authorize");
  const sent = JSON.parse(fetcher.requests[0].body);
  assertEquals([sent.p_cap_milli, sent.p_calls_per_minute, sent.p_turn_id], [15_000, 60, "t"]);
});

Deno.test("a refusal from the ledger keeps its code", async () => {
  const { ledger: subject } = ledger({ error: "credits_exhausted", balance });
  const outcome = await subject.authorize(call);
  assertEquals(outcome.kind === "refused" ? outcome.code : null, "credits_exhausted");
});

Deno.test("ledger failures and replies without a balance reject", async () => {
  await assertRejects(() => ledger({}, 500).ledger.balance("u", call.now));
  await assertRejects(() => ledger({ nope: 1 }).ledger.debit(call, 3));
});

Deno.test("the balance carries the store of the active period", async () => {
  const { ledger: subject } = ledger({ ...balance, store: "app_store" });
  assertEquals((await subject.balance("u", call.now)).store, "app_store");
  const { ledger: unknown } = ledger({ ...balance, store: null });
  assertEquals((await unknown.balance("u", call.now)).store, null);
});
