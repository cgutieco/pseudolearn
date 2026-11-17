import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import type { GooglePlayPurchases } from "../../../../supabase/functions/agent-credits/domain/google_play_purchase.ts";
import {
  GooglePlayNotificationReader,
  type PushAuthenticity,
} from "../../../../supabase/functions/store-events/infrastructure/google_play_notification_reader.ts";
import { pubSubEnvelope } from "../../../support/google_signing.ts";

const packageName = "com.pseudolearn.app";
const catalog = { packageName, acceptsTestPurchases: false };
const user = "6f1c2c1e-0000-4000-8000-000000000001";

class RecordingAuthenticity implements PushAuthenticity {
  readonly seen: (string | null)[] = [];

  constructor(private readonly accepts = true) {}

  verify(authorization: string | null): Promise<void> {
    this.seen.push(authorization);
    return this.accepts ? Promise.resolve() : Promise.reject(new AgentError("invalid_signature"));
  }
}

class ScriptedPurchases implements GooglePlayPurchases {
  readonly asked: string[] = [];

  subscription(token: string) {
    this.asked.push(`subscription:${token}`);
    return Promise.resolve({
      startTime: "2026-11-01T00:00:00Z",
      subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
      externalAccountIdentifiers: { obfuscatedExternalAccountId: user },
      lineItems: [{
        productId: "pseudolearn.nodo.monthly",
        expiryTime: "2026-12-01T00:00:00Z",
        latestSuccessfulOrderId: "GPA.2",
      }],
    });
  }

  oneTimeProduct(productId: string, token: string) {
    this.asked.push(`product:${productId}:${token}`);
    return Promise.resolve({ purchaseState: 0, obfuscatedExternalAccountId: user });
  }
}

function reader(authenticity = new RecordingAuthenticity(), purchases = new ScriptedPurchases()) {
  return {
    purchases,
    authenticity,
    reader: new GooglePlayNotificationReader(authenticity, purchases, catalog),
  };
}

function notification(fields: Record<string, unknown>) {
  return pubSubEnvelope({ version: "1.0", packageName, eventTimeMillis: "1", ...fields });
}

Deno.test("a renewal is read from the current subscription state", async () => {
  const { reader: subject, purchases, authenticity } = reader();
  const events = await subject.read(
    notification({
      subscriptionNotification: { version: "1.0", notificationType: 2, purchaseToken: "t" },
    }),
    "Bearer jwt",
  );
  assertEquals(authenticity.seen, ["Bearer jwt"]);
  assertEquals(purchases.asked, ["subscription:t"]);
  assertEquals(events.length, 1);
  assertEquals(
    events[0].kind === "purchase" ? events[0].purchase.transactionId : null,
    "google_play:GPA.2",
  );
});

Deno.test("a purchased top-up is read from the one-time product", async () => {
  const { reader: subject, purchases } = reader();
  const events = await subject.read(
    notification({
      oneTimeProductNotification: {
        notificationType: 1,
        purchaseToken: "t",
        sku: "pseudolearn.nodo.topup150",
      },
    }),
    "Bearer jwt",
  );
  assertEquals(purchases.asked, ["product:pseudolearn.nodo.topup150:t"]);
  assertEquals(events[0].kind === "purchase" ? events[0].userHint : null, user);
});

Deno.test("revocations and voided purchases need no API call", async () => {
  const { reader: subject, purchases } = reader();
  const revoked = await subject.read(
    notification({ subscriptionNotification: { notificationType: 12, purchaseToken: "t" } }),
    "Bearer jwt",
  );
  const voided = await subject.read(
    notification({
      voidedPurchaseNotification: { purchaseToken: "u", productType: 2, refundType: 1 },
    }),
    "Bearer jwt",
  );
  assertEquals(revoked[0].kind, "revocation");
  assertEquals(
    voided[0].kind === "revocation" ? voided[0].revocation.transactionId : null,
    "google_play:u",
  );
  assertEquals(purchases.asked, []);
});

Deno.test("test notifications are acknowledged as ignored", async () => {
  const { reader: subject } = reader();
  assertEquals(
    await subject.read(notification({ testNotification: { version: "1.0" } }), "Bearer jwt"),
    [
      { kind: "ignored", reason: "test" },
    ],
  );
});

Deno.test("an unauthenticated push is refused before reading the body", async () => {
  const { reader: subject, purchases } = reader(new RecordingAuthenticity(false));
  await assertRejects(() => subject.read("not json", null), AgentError, "invalid_signature");
  assertEquals(purchases.asked, []);
});

Deno.test("a body that is not a Pub/Sub message is an invalid request", async () => {
  for (
    const body of [
      "{",
      JSON.stringify({}),
      JSON.stringify({ message: { data: 7 } }),
      JSON.stringify({ message: { data: "%%%" } }),
    ]
  ) {
    const error = await assertRejects(() => reader().reader.read(body, "Bearer jwt"), AgentError);
    assertEquals(error.code, "invalid_request");
  }
});
