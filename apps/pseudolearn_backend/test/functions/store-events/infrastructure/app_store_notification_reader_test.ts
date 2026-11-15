import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { AppleSignedDataVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/apple_signed_data_verifier.ts";
import { AppStoreNotificationReader } from "../../../../supabase/functions/store-events/infrastructure/app_store_notification_reader.ts";
import {
  appStoreCatalog,
  signJws,
  subscriptionTransaction,
  testNow,
  testRoot,
} from "../../../support/app_store_signing.ts";

const reader = new AppStoreNotificationReader(
  new AppleSignedDataVerifier({ trustedRoots: [testRoot], now: () => testNow }),
  appStoreCatalog,
);

async function notification(data: Record<string, unknown>): Promise<string> {
  return JSON.stringify({ signedPayload: await signJws({ notificationType: "DID_RENEW", data }) });
}

Deno.test("a signed notification yields the event of its signed transaction", async () => {
  const body = await notification({
    signedTransactionInfo: await signJws(subscriptionTransaction()),
  });
  const [event] = await reader.read(body);
  assertEquals(event.kind, "purchase");
});

Deno.test("a notification without a transaction is ignored", async () => {
  const [event] = await reader.read(await notification({}));
  assertEquals(event.kind, "ignored");
});

Deno.test("an unsigned payload or transaction is refused as an invalid signature", async () => {
  const unsigned = JSON.stringify({ signedPayload: "a.b.c" });
  assertEquals(
    (await assertRejects(() => reader.read(unsigned), AgentError)).code,
    "invalid_signature",
  );
  const forgedTransaction = await notification({ signedTransactionInfo: "x.y.z" });
  assertEquals(
    (await assertRejects(() => reader.read(forgedTransaction), AgentError)).code,
    "invalid_signature",
  );
});

Deno.test("a body without a signed payload is an invalid request", async () => {
  assertEquals((await assertRejects(() => reader.read("{}"), AgentError)).code, "invalid_request");
  assertEquals(
    (await assertRejects(() => reader.read("nope"), AgentError)).code,
    "invalid_request",
  );
});
