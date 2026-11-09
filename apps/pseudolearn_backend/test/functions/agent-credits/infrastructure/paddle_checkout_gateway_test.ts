import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import { PaddleCheckoutGateway } from "../../../../supabase/functions/agent-credits/infrastructure/paddle_checkout_gateway.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";

const settings = {
  apiBase: "https://sandbox-api.paddle.com",
  apiKey: "pdl_key",
  webhookSecret: "secret",
  prices: { monthly: "pri_m", monthly_trial: "pri_mt", top_up: "pri_t" },
};

function gateway(reply: unknown, status = 200) {
  const fetcher = new FakeFetcher(() => Response.json(reply, { status }));
  return { fetcher, subject: new PaddleCheckoutGateway(settings, fetcher.fetch) };
}

Deno.test("a checkout creates a transaction for the price and the account", async () => {
  const { fetcher, subject } = gateway({
    data: { checkout: { url: "https://pseudolearn.app/checkout?_ptxn=txn_1" } },
  });
  assertEquals(
    await subject.open("user-1", "monthly_trial"),
    "https://pseudolearn.app/checkout?_ptxn=txn_1",
  );
  const request = fetcher.requests[0];
  assertEquals(request.url, "https://sandbox-api.paddle.com/transactions");
  assertEquals(request.headers.get("authorization"), "Bearer pdl_key");
  const sent = JSON.parse(request.body);
  assertEquals(sent.items, [{ price_id: "pri_mt", quantity: 1 }]);
  assertEquals(sent.custom_data, { user_id: "user-1" });
});

Deno.test("the portal opens a session for the customer", async () => {
  const { fetcher, subject } = gateway({
    data: { urls: { general: { overview: "https://customer-portal.paddle.com/x" } } },
  });
  assertEquals(await subject.portal("ctm/1"), "https://customer-portal.paddle.com/x");
  assertEquals(
    fetcher.requests[0].url,
    "https://sandbox-api.paddle.com/customers/ctm%2F1/portal-sessions",
  );
});

Deno.test("a Paddle failure or a reply without a secure link is an upstream error", async () => {
  const failed = await assertRejects(
    () => gateway({}, 400).subject.open("u", "top_up"),
    AgentError,
  );
  assertEquals(failed.code, "upstream_error");
  const insecure = gateway({ data: { checkout: { url: "http://x" } } }).subject;
  assertEquals(
    (await assertRejects(() => insecure.open("u", "top_up"), AgentError)).code,
    "upstream_error",
  );
  const empty = gateway({ data: null }).subject;
  assertEquals((await assertRejects(() => empty.portal("c"), AgentError)).code, "upstream_error");
});
