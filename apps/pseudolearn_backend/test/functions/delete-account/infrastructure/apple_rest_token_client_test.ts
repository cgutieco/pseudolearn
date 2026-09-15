import { assertEquals } from "@std/assert";
import {
  AppleRestTokenClient,
  appleRevokeUrl,
  appleTokenUrl,
} from "../../../../supabase/functions/delete-account/infrastructure/apple_rest_token_client.ts";
import { FakeFetcher, unsignedJwt } from "../../../support/fake_fetcher.ts";

const clientId = "com.pseudolearn.app";

function client(fetcher: FakeFetcher, clientSecret = () => Promise.resolve("client-secret")) {
  return new AppleRestTokenClient({ clientId, fetcher: fetcher.fetch, clientSecret });
}

function tokenBody(overrides: Record<string, unknown> = {}): Response {
  return Response.json({
    access_token: "apple-access",
    refresh_token: "apple-refresh",
    id_token: unsignedJwt({ sub: "apple-subject", aud: clientId }),
    ...overrides,
  });
}

Deno.test("exchange posts the code with client credentials and returns the refresh token", async () => {
  const fetcher = new FakeFetcher(() => tokenBody());

  const exchange = await client(fetcher).exchange("auth-code");

  assertEquals(exchange, {
    kind: "exchanged",
    subject: "apple-subject",
    token: { value: "apple-refresh", hint: "refresh_token" },
  });
  const request = fetcher.requests[0];
  assertEquals(request.url, appleTokenUrl);
  assertEquals(request.headers.get("content-type"), "application/x-www-form-urlencoded");
  assertEquals(Object.fromEntries(new URLSearchParams(request.body)), {
    code: "auth-code",
    grant_type: "authorization_code",
    client_id: clientId,
    client_secret: "client-secret",
  });
});

Deno.test("exchange falls back to the access token when no refresh token is issued", async () => {
  const fetcher = new FakeFetcher(() => tokenBody({ refresh_token: undefined }));

  const exchange = await client(fetcher).exchange("auth-code");

  assertEquals(exchange.kind === "exchanged" && exchange.token, {
    value: "apple-access",
    hint: "access_token",
  });
});

Deno.test("exchange fails on invalid_grant, bad JSON, missing tokens or foreign audience", async () => {
  const responders: Array<() => Response> = [
    () => Response.json({ error: "invalid_grant" }, { status: 400 }),
    () => new Response("not json", { status: 200 }),
    () => Response.json({ access_token: "a", refresh_token: "r" }),
    () => tokenBody({ id_token: "not-a-jwt" }),
    () => tokenBody({ id_token: unsignedJwt({ aud: clientId }) }),
    () => tokenBody({ id_token: unsignedJwt({ sub: "s", aud: "com.other.app" }) }),
    () => tokenBody({ refresh_token: "", access_token: "" }),
  ];
  for (const responder of responders) {
    const exchange = await client(new FakeFetcher(responder)).exchange("auth-code");
    assertEquals(exchange, { kind: "failed" });
  }
});

Deno.test("exchange fails without throwing when the network or the secret fails", async () => {
  const offline = new FakeFetcher(() => Promise.reject(new TypeError("offline")));
  assertEquals(await client(offline).exchange("code"), { kind: "failed" });

  const noSecret = new FakeFetcher(() => tokenBody());
  const exchange = await client(noSecret, () => Promise.reject(new Error("bad key"))).exchange("c");
  assertEquals(exchange, { kind: "failed" });
  assertEquals(noSecret.requests.length, 0);
});

Deno.test("revoke posts the token with its hint and succeeds only on 200", async () => {
  const fetcher = new FakeFetcher(() => new Response(null, { status: 200 }));

  const revoked = await client(fetcher).revoke({ value: "apple-refresh", hint: "refresh_token" });

  assertEquals(revoked, true);
  assertEquals(fetcher.requests[0].url, appleRevokeUrl);
  assertEquals(Object.fromEntries(new URLSearchParams(fetcher.requests[0].body)), {
    token: "apple-refresh",
    token_type_hint: "refresh_token",
    client_id: clientId,
    client_secret: "client-secret",
  });
});

Deno.test("revoke reports failure on Apple errors and network failures", async () => {
  const token = { value: "t", hint: "access_token" } as const;
  const rejected = new FakeFetcher(() =>
    Response.json({ error: "invalid_client" }, { status: 400 })
  );
  const accepted = new FakeFetcher(() => new Response(null, { status: 204 }));
  const offline = new FakeFetcher(() => Promise.reject(new TypeError("offline")));

  assertEquals(await client(rejected).revoke(token), false);
  assertEquals(await client(accepted).revoke(token), false);
  assertEquals(await client(offline).revoke(token), false);
});
