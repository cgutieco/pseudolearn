import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import {
  androidPublisherScope,
  GoogleAccessTokens,
  googleServiceAccountOf,
  googleTokenEndpoint,
} from "../../../../supabase/functions/agent-credits/infrastructure/google_service_account.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";
import { googleTestKey, segmentsOf } from "../../../support/google_signing.ts";

const key = await googleTestKey();
const account = {
  clientEmail: "play@pseudolearn.iam.gserviceaccount.com",
  privateKeyPem: key.privateKeyPem,
};

function tokenReply(token = "access-1", expiresIn = 3600) {
  return Response.json({ access_token: token, expires_in: expiresIn, token_type: "Bearer" });
}

Deno.test("the credential JSON yields its email and private key", () => {
  const json = JSON.stringify({ type: "service_account", client_email: "a@b", private_key: "pem" });
  assertEquals(googleServiceAccountOf(json), { clientEmail: "a@b", privateKeyPem: "pem" });
});

Deno.test("a broken or incomplete credential JSON is not an account", () => {
  assertEquals(googleServiceAccountOf(""), null);
  assertEquals(googleServiceAccountOf("{"), null);
  assertEquals(googleServiceAccountOf("[]"), null);
  assertEquals(googleServiceAccountOf(JSON.stringify({ client_email: "a@b" })), null);
  assertEquals(
    googleServiceAccountOf(JSON.stringify({ client_email: "", private_key: "pem" })),
    null,
  );
});

Deno.test("the token request carries a signed assertion for the publisher scope", async () => {
  const fetcher = new FakeFetcher(() => tokenReply());
  const tokens = new GoogleAccessTokens(account, fetcher.fetch, () => 1_800_000_000_000);
  assertEquals(await tokens.token(), "access-1");
  const request = fetcher.requests[0];
  assertEquals(request.url, googleTokenEndpoint);
  assertEquals(request.method, "POST");
  const form = new URLSearchParams(request.body);
  assertEquals(form.get("grant_type"), "urn:ietf:params:oauth:grant-type:jwt-bearer");
  const assertion = form.get("assertion") ?? "";
  const { header, claims } = segmentsOf(assertion);
  assertEquals(header.alg, "RS256");
  assertEquals(claims, {
    iss: account.clientEmail,
    scope: androidPublisherScope,
    aud: googleTokenEndpoint,
    iat: 1_800_000_000,
    exp: 1_800_003_600,
  });
  const [head, body, signature] = assertion.split(".");
  const signatureBytes = Uint8Array.from(
    atob(signature.replaceAll("-", "+").replaceAll("_", "/")),
    (character) => character.charCodeAt(0),
  );
  const valid = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5",
    key.publicKey,
    signatureBytes,
    new TextEncoder().encode(`${head}.${body}`),
  );
  assertEquals(valid, true);
});

Deno.test("a token is reused until it nears expiry", async () => {
  let now = 1_800_000_000_000;
  let issued = 0;
  const fetcher = new FakeFetcher(() => tokenReply(`access-${++issued}`));
  const tokens = new GoogleAccessTokens(account, fetcher.fetch, () => now);
  assertEquals(await tokens.token(), "access-1");
  now += 3_000_000;
  assertEquals(await tokens.token(), "access-1");
  now += 400_000;
  assertEquals(await tokens.token(), "access-2");
  assertEquals(fetcher.requests.length, 2);
});

Deno.test("a refused or malformed token reply is an upstream error", async () => {
  for (
    const reply of [new Response("no", { status: 401 }), Response.json({ token_type: "Bearer" })]
  ) {
    const tokens = new GoogleAccessTokens(account, new FakeFetcher(() => reply).fetch);
    const error = await assertRejects(() => tokens.token(), AgentError);
    assertEquals(error.code, "upstream_error");
  }
});

Deno.test("a token reply without a lifetime is fetched again next time", async () => {
  const fetcher = new FakeFetcher(() => Response.json({ access_token: "short" }));
  const tokens = new GoogleAccessTokens(account, fetcher.fetch);
  await tokens.token();
  await tokens.token();
  assertEquals(fetcher.requests.length, 2);
});
