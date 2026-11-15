import { assertEquals } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { createStoreEventsHandler } from "../../../../supabase/functions/store-events/http/store_events_handler.ts";
import type { StoreEventReader } from "../../../../supabase/functions/store-events/domain/store_event.ts";
import { FakeLedger } from "../../../support/agent_fakes.ts";

const signatures: (string | null)[] = [];
const reader: StoreEventReader = {
  read(body, signature) {
    signatures.push(signature);
    if (body === "forged") return Promise.reject(new AgentError("invalid_signature"));
    return Promise.resolve([{ kind: "ignored", reason: body }]);
  },
};

function handler(ready = true) {
  const entries: Record<string, unknown>[] = [];
  const handle = createStoreEventsHandler({
    routes: new Map([["paddle", { reader, signatureHeader: "paddle-signature" }]]),
    dependencies: ready ? { ledger: new FakeLedger(), clock: { now: () => new Date() } } : null,
  }, (entry) => entries.push(entry));
  return { entries, handle };
}

function post(path: string, body: string, headers: Record<string, string> = {}): Request {
  return new Request(`http://localhost/store-events/${path}`, { method: "POST", body, headers });
}

Deno.test("an event is read with its signature header and answered with outcomes", async () => {
  const { entries, handle } = handler();
  const response = await handle(post("paddle/", "ping", { "paddle-signature": "ts=1;h1=a" }));
  assertEquals(await response.json(), { outcomes: ["ignored:ping"] });
  assertEquals(signatures.at(-1), "ts=1;h1=a");
  assertEquals(entries[0], { event: "store_event", store: "paddle", outcomes: ["ignored:ping"] });
});

Deno.test("a forged event is refused and logged without its body", async () => {
  const { entries, handle } = handler();
  const response = await handle(post("paddle", "forged"));
  assertEquals(response.status, 401);
  assertEquals(entries[0], { event: "store_event", store: "paddle", code: "invalid_signature" });
});

Deno.test("unknown stores, other methods and a missing ledger are refused", async () => {
  assertEquals((await handler().handle(post("google-play", "x"))).status, 404);
  const get = new Request("http://localhost/store-events/paddle");
  assertEquals((await handler().handle(get)).status, 405);
  assertEquals((await handler(false).handle(post("paddle", "x"))).status, 500);
});

Deno.test("an oversized body is refused before reading it", async () => {
  const response = await handler().handle(post("paddle", "x".repeat(1_000_001)));
  assertEquals(response.status, 413);
});
