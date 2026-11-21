import { assertEquals } from "@std/assert";
import type { GooglePlayPurchases } from "../../../../supabase/functions/agent-credits/domain/google_play_purchase.ts";
import { GooglePlayPurchaseVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/google_play_purchase_verifier.ts";

const catalog = { packageName: "com.pseudolearn.app", acceptsTestPurchases: false };

class ScriptedPurchases implements GooglePlayPurchases {
  readonly asked: string[] = [];

  constructor(
    private readonly subscriptionReply: Record<string, unknown> | null = null,
    private readonly productReply: Record<string, unknown> | null = null,
  ) {}

  subscription(token: string) {
    this.asked.push(`subscription:${token}`);
    return Promise.resolve(this.subscriptionReply);
  }

  oneTimeProduct(productId: string, token: string) {
    this.asked.push(`product:${productId}:${token}`);
    return Promise.resolve(this.productReply);
  }
}

const activePlan = {
  startTime: "2026-11-01T00:00:00Z",
  subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
  lineItems: [{ productId: "pseudolearn.nodo.monthly", expiryTime: "2026-12-01T00:00:00Z" }],
};

function claim(productId: string, evidence = "token-1", store = "google_play") {
  return { store, productId, transactionId: "GPA.1", evidence };
}

Deno.test("the plan is verified against its subscription by purchase token", async () => {
  const purchases = new ScriptedPurchases(activePlan);
  const verified = await new GooglePlayPurchaseVerifier(purchases, catalog)
    .verify(claim("pseudolearn.nodo.monthly"));
  assertEquals(verified?.product, "monthly");
  assertEquals(verified?.originalTransactionId, "token-1");
  assertEquals(purchases.asked, ["subscription:token-1"]);
});

Deno.test("the top-up is verified as a one-time product", async () => {
  const purchases = new ScriptedPurchases(null, { purchaseState: 0 });
  const verified = await new GooglePlayPurchaseVerifier(purchases, catalog)
    .verify(claim("pseudolearn.nodo.topup150"));
  assertEquals(verified?.transactionId, "google_play:token-1");
  assertEquals(purchases.asked, ["product:pseudolearn.nodo.topup150:token-1"]);
});

Deno.test("a token the store does not know verifies nothing", async () => {
  const verifier = new GooglePlayPurchaseVerifier(new ScriptedPurchases(), catalog);
  assertEquals(await verifier.verify(claim("pseudolearn.nodo.monthly")), null);
  assertEquals(await verifier.verify(claim("pseudolearn.nodo.topup150")), null);
});

Deno.test("other stores, empty evidence, the trial and foreign products never reach Google", async () => {
  const purchases = new ScriptedPurchases(activePlan, { purchaseState: 0 });
  const verifier = new GooglePlayPurchaseVerifier(purchases, catalog);
  assertEquals(
    await verifier.verify(claim("pseudolearn.nodo.monthly", "token", "app_store")),
    null,
  );
  assertEquals(await verifier.verify(claim("pseudolearn.nodo.monthly", "")), null);
  assertEquals(await verifier.verify(claim("pseudolearn.nodo.trial")), null);
  assertEquals(await verifier.verify(claim("com.other.product")), null);
  assertEquals(purchases.asked, []);
});
