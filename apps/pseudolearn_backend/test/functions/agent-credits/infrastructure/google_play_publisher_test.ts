import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { GooglePlayPublisher } from "../../../../supabase/functions/agent-credits/infrastructure/google_play_publisher.ts";
import { GoogleAccessTokens } from "../../../../supabase/functions/agent-credits/infrastructure/google_service_account.ts";
import { FakeFetcher, type FetchResponder } from "../../../support/fake_fetcher.ts";
import { googleTestKey } from "../../../support/google_signing.ts";

const key = await googleTestKey();
const base = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications";

function publisherWith(responder: FetchResponder) {
  const fetcher = new FakeFetcher((request) =>
    request.url.startsWith("https://oauth2.googleapis.com/")
      ? Response.json({ access_token: "access-1", expires_in: 3600 })
      : responder(request)
  );
  const tokens = new GoogleAccessTokens(
    { clientEmail: "play@x.iam.gserviceaccount.com", privateKeyPem: key.privateKeyPem },
    fetcher.fetch,
  );
  return {
    fetcher,
    publisher: new GooglePlayPublisher("com.pseudolearn.app", tokens, fetcher.fetch),
  };
}

Deno.test("a subscription is read from subscriptionsv2 with the access token", async () => {
  const { fetcher, publisher } = publisherWith(() => Response.json({ subscriptionState: "S" }));
  assertEquals(await publisher.subscription("a/b token"), { subscriptionState: "S" });
  const request = fetcher.requests[1];
  assertEquals(
    request.url,
    `${base}/com.pseudolearn.app/purchases/subscriptionsv2/tokens/a%2Fb%20token`,
  );
  assertEquals(request.method, "GET");
  assertEquals(request.headers.get("authorization"), "Bearer access-1");
});

Deno.test("a one-time product is read with its product id and token", async () => {
  const { fetcher, publisher } = publisherWith(() => Response.json({ purchaseState: 0 }));
  assertEquals(await publisher.oneTimeProduct("pseudolearn.nodo.topup150", "tok"), {
    purchaseState: 0,
  });
  assertEquals(
    fetcher.requests[1].url,
    `${base}/com.pseudolearn.app/purchases/products/pseudolearn.nodo.topup150/tokens/tok`,
  );
});

Deno.test("an unknown or invalid token is no purchase", async () => {
  for (const status of [400, 404, 410]) {
    const { publisher } = publisherWith(() => new Response("{}", { status }));
    assertEquals(await publisher.subscription("tok"), null);
  }
});

Deno.test("a body that is not an object is no purchase", async () => {
  const { publisher } = publisherWith(() => Response.json([1, 2]));
  assertEquals(await publisher.oneTimeProduct("p", "tok"), null);
});

Deno.test("other API failures are upstream errors to retry", async () => {
  for (const status of [401, 403, 500, 503]) {
    const { publisher } = publisherWith(() => new Response("{}", { status }));
    const error = await assertRejects(() => publisher.subscription("tok"), AgentError);
    assertEquals(error.code, "upstream_error");
  }
});
