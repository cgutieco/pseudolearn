import { assertEquals } from "@std/assert";
import { createAgentHandler } from "../../../../supabase/functions/agent-responses/http/agent_handler.ts";
import type { AgentEvent } from "../../../../supabase/functions/agent-responses/http/agent_handler.ts";
import {
  agentDependencies,
  agentRequest,
  FakeLedger,
  FakeModel,
  FakeUsers,
  okReply,
} from "../../../support/agent_fakes.ts";

function handler(setup: Parameters<typeof createAgentHandler>[0], events: AgentEvent[] = []) {
  return createAgentHandler(setup, (event) => events.push(event), () => 0);
}

async function errorOf(response: Response): Promise<Record<string, unknown>> {
  return (await response.json()).error;
}

Deno.test("without a provider key the proxy answers model_unconfigured", async () => {
  const response = await handler({ kind: "unavailable", code: "model_unconfigured" })(
    agentRequest(),
  );
  assertEquals(response.status, 503);
  assertEquals((await errorOf(response)).code, "model_unconfigured");
});

Deno.test("an invalid session is unauthenticated and never reaches the model", async () => {
  const model = new FakeModel();
  const dependencies = agentDependencies({ users: new FakeUsers(null), model });
  const response = await handler({ kind: "ready", dependencies })(agentRequest());
  assertEquals(response.status, 401);
  assertEquals(model.bodies.length, 0);
});

Deno.test("a missing bearer token is unauthenticated", async () => {
  const response = await handler({ kind: "ready", dependencies: agentDependencies() })(
    agentRequest(undefined, { authorization: "" }),
  );
  assertEquals((await errorOf(response)).code, "unauthenticated");
});

Deno.test("no balance and the per request cap are refused before calling the model", async () => {
  for (const [code, status] of [["subscription_required", 402], ["request_cap", 429]] as const) {
    const ledger = new FakeLedger();
    ledger.refusal = code;
    const model = new FakeModel();
    const response = await handler({
      kind: "ready",
      dependencies: agentDependencies({ ledger, model }),
    })(
      agentRequest(),
    );
    assertEquals(response.status, status);
    assertEquals((await errorOf(response)).code, code);
    assertEquals(model.bodies.length, 0);
  }
});

Deno.test("a provider failure does not debit", async () => {
  const ledger = new FakeLedger();
  const model = new FakeModel(okReply({ error: "boom" }, 500));
  const response = await handler({
    kind: "ready",
    dependencies: agentDependencies({ ledger, model }),
  })(
    agentRequest(),
  );
  assertEquals(response.status, 502);
  assertEquals((await errorOf(response)).retryable, true);
  assertEquals(ledger.debits.length, 0);
});

Deno.test("a provider rate limit is retryable and does not debit", async () => {
  const ledger = new FakeLedger();
  const model = new FakeModel({ ...okReply({}, 429), retryAfter: "20" });
  const response = await handler({
    kind: "ready",
    dependencies: agentDependencies({ ledger, model }),
  })(
    agentRequest(),
  );
  assertEquals((await errorOf(response)).code, "upstream_rate_limited");
  assertEquals(ledger.debits.length, 0);
});

Deno.test("a reply without usage is an upstream error without debit", async () => {
  const ledger = new FakeLedger();
  const model = new FakeModel(okReply({ output: [] }));
  const response = await handler({
    kind: "ready",
    dependencies: agentDependencies({ ledger, model }),
  })(
    agentRequest(),
  );
  assertEquals(response.status, 502);
  assertEquals(ledger.debits.length, 0);
});

Deno.test("a successful call debits the real usage and returns balance headers", async () => {
  const ledger = new FakeLedger();
  const events: AgentEvent[] = [];
  const response = await handler(
    { kind: "ready", dependencies: agentDependencies({ ledger }) },
    events,
  )(agentRequest());
  assertEquals(response.status, 200);
  assertEquals(ledger.debits[0].milli, 1_220);
  assertEquals(ledger.debits[0].call.turnId, "turn-1");
  assertEquals(response.headers.get("x-pseudolearn-credits-remaining"), "270");
  assertEquals(response.headers.get("x-pseudolearn-credits-top-up"), "150");
  assertEquals(response.headers.get("x-pseudolearn-credits-trial"), "false");
  assertEquals(events, [{ event: "agent_responses", status: 200, code: "ok", milliseconds: 0 }]);
});

Deno.test("only POST is allowed and malformed requests are invalid", async () => {
  const ready = handler({ kind: "ready", dependencies: agentDependencies() });
  assertEquals((await ready(agentRequest(undefined, {}, "GET"))).status, 405);
  assertEquals((await errorOf(await ready(agentRequest("{nope")))).code, "invalid_request");
  assertEquals(
    (await errorOf(await ready(agentRequest(undefined, { "x-pseudolearn-turn-id": "" })))).detail,
    "turn",
  );
  const big = agentRequest("x".repeat(1_000_001));
  assertEquals((await ready(big)).status, 413);
});

Deno.test("errors carry the request id and hide internal details", async () => {
  const ledger = new FakeLedger();
  ledger.refusal = "credits_exhausted";
  const response = await handler({ kind: "ready", dependencies: agentDependencies({ ledger }) })(
    agentRequest(),
  );
  const error = await errorOf(response);
  assertEquals(error.requestId, "req-1");
  assertEquals("detail" in error, false);
});
