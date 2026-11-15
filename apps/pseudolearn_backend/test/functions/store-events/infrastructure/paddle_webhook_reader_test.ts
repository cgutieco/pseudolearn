import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { PaddleWebhookReader } from "../../../../supabase/functions/store-events/infrastructure/paddle_webhook_reader.ts";

const secret = "pdl_ntfset_secret";
const now = Date.UTC(2026, 10, 9, 12);
const timestamp = String(now / 1000);
const reader = new PaddleWebhookReader(
  secret,
  { monthly: new Set(["pri_m"]), topUp: "pri_t" },
  () => now,
);
const body = JSON.stringify({
  event_type: "transaction.completed",
  data: { id: "txn_1", custom_data: { user_id: "user-1" }, items: [{ price: { id: "pri_t" } }] },
});

async function hmac(message: string, key = secret): Promise<string> {
  const encoder = new TextEncoder();
  const imported = await crypto.subtle.importKey(
    "raw",
    encoder.encode(key),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const digest = new Uint8Array(
    await crypto.subtle.sign("HMAC", imported, encoder.encode(message)),
  );
  return Array.from(digest, (byte) => byte.toString(16).padStart(2, "0")).join("");
}

async function refusal(signature: string | null, payload = body): Promise<string> {
  return (await assertRejects(() => reader.read(payload, signature), AgentError)).code;
}

Deno.test("a correctly signed webhook is read as its event", async () => {
  const signature = `ts=${timestamp};h1=${await hmac(`${timestamp}:${body}`)}`;
  const [event] = await reader.read(body, signature);
  assertEquals(event.kind === "purchase" && event.purchase.transactionId, "paddle:txn_1");
});

Deno.test("any of several signatures may match during secret rotation", async () => {
  const valid = await hmac(`${timestamp}:${body}`);
  const signature = `ts=${timestamp};h1=${await hmac("x", "old")};h1=${valid}`;
  assertEquals((await reader.read(body, signature)).length, 1);
});

Deno.test("a wrong, missing, stale or tampered signature is refused", async () => {
  assertEquals(
    await refusal(`ts=${timestamp};h1=${await hmac(`${timestamp}:${body}`, "other")}`),
    "invalid_signature",
  );
  assertEquals(await refusal(null), "invalid_signature");
  assertEquals(await refusal(`h1=${await hmac(`${timestamp}:${body}`)}`), "invalid_signature");
  const stale = String(now / 1000 - 301);
  assertEquals(
    await refusal(`ts=${stale};h1=${await hmac(`${stale}:${body}`)}`),
    "invalid_signature",
  );
  const signature = `ts=${timestamp};h1=${await hmac(`${timestamp}:${body}`)}`;
  assertEquals(await refusal(signature, body.replace("txn_1", "txn_2")), "invalid_signature");
});

Deno.test("a signed body that is not JSON is an invalid request", async () => {
  const signature = `ts=${timestamp};h1=${await hmac(`${timestamp}:nope`)}`;
  assertEquals(await refusal(signature, "nope"), "invalid_request");
});
