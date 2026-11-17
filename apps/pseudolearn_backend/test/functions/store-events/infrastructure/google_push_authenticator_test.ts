import { assertEquals, assertRejects } from "@std/assert";
import { AgentError } from "../../../../supabase/functions/agent-responses/domain/agent_error.ts";
import {
  GooglePushAuthenticator,
  googleSigningKeysUrl,
} from "../../../../supabase/functions/store-events/infrastructure/google_push_authenticator.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";
import { googleTestKey, signedJwt } from "../../../support/google_signing.ts";

const key = await googleTestKey("kid-1");
const stranger = await googleTestKey("kid-1");
const settings = {
  audience: "https://x.supabase.co/functions/v1/store-events/google-play",
  serviceAccountEmail: "rtdn@pseudolearn.iam.gserviceaccount.com",
};
const nowMilliseconds = 1_800_000_000_000;
const claims = {
  iss: "https://accounts.google.com",
  aud: settings.audience,
  email: settings.serviceAccountEmail,
  email_verified: true,
  iat: 1_800_000_000 - 60,
  exp: 1_800_000_000 + 3_540,
  sub: "1234",
};

function authenticator(keys: unknown[] = [key.publicJwk]) {
  const fetcher = new FakeFetcher(() => Response.json({ keys }));
  return {
    fetcher,
    authenticator: new GooglePushAuthenticator(settings, fetcher.fetch, () => nowMilliseconds),
  };
}

async function rejected(authorization: string | null, keys?: unknown[]) {
  const error = await assertRejects(
    () => authenticator(keys).authenticator.verify(authorization),
    AgentError,
  );
  assertEquals(error.code, "invalid_signature");
}

Deno.test("a push signed by Google for our audience and account is accepted", async () => {
  const { fetcher, authenticator: verifier } = authenticator();
  await verifier.verify(`Bearer ${await signedJwt(key, claims)}`);
  await verifier.verify(
    `bearer ${await signedJwt(key, { ...claims, iss: "accounts.google.com" })}`,
  );
  assertEquals(fetcher.requests.map((request) => request.url), [googleSigningKeysUrl]);
});

Deno.test("a missing or malformed authorization is refused", async () => {
  await rejected(null);
  await rejected("");
  await rejected("Basic abc");
  await rejected("Bearer not-a-jwt");
  await rejected("Bearer a.b.c");
});

Deno.test("a token for another audience, account, issuer or unverified email is refused", async () => {
  for (
    const changed of [
      { aud: "https://other.example" },
      { email: "someone@else.iam.gserviceaccount.com" },
      { iss: "https://evil.example" },
      { email_verified: false },
      { email_verified: "true" },
    ]
  ) {
    await rejected(`Bearer ${await signedJwt(key, { ...claims, ...changed })}`);
  }
});

Deno.test("an expired token or one issued in the future is refused", async () => {
  await rejected(`Bearer ${await signedJwt(key, { ...claims, exp: 1_800_000_000 - 400 })}`);
  await rejected(`Bearer ${await signedJwt(key, { ...claims, iat: 1_800_000_000 + 400 })}`);
  await rejected(`Bearer ${await signedJwt(key, { ...claims, exp: undefined })}`);
});

Deno.test("a token within the clock skew is accepted", async () => {
  const skewed = { ...claims, exp: 1_800_000_000 - 200, iat: 1_800_000_000 + 200 };
  await authenticator().authenticator.verify(`Bearer ${await signedJwt(key, skewed)}`);
});

Deno.test("a signature from another key, another algorithm or an unknown key id is refused", async () => {
  await rejected(`Bearer ${await signedJwt(stranger, claims)}`);
  await rejected(`Bearer ${await signedJwt(key, claims, { alg: "HS256", kid: "kid-1" })}`);
  await rejected(`Bearer ${await signedJwt(key, claims, { alg: "RS256" })}`);
  await rejected(`Bearer ${await signedJwt(key, claims)}`, []);
  await rejected(`Bearer ${await signedJwt(key, claims)}`, [{ kid: "kid-1", kty: "EC" }, "x"]);
});

Deno.test("an unknown key id refreshes Google's keys once per request", async () => {
  const rotated = await googleTestKey("kid-2");
  let served: unknown[] = [key.publicJwk];
  const fetcher = new FakeFetcher(() => Response.json({ keys: served }));
  const verifier = new GooglePushAuthenticator(settings, fetcher.fetch, () => nowMilliseconds);
  await verifier.verify(`Bearer ${await signedJwt(key, claims)}`);
  served = [rotated.publicJwk];
  await verifier.verify(`Bearer ${await signedJwt(rotated, claims)}`);
  assertEquals(fetcher.requests.length, 2);
});

Deno.test("Google's keys being unreachable is an upstream error", async () => {
  const fetcher = new FakeFetcher(() => new Response("down", { status: 503 }));
  const verifier = new GooglePushAuthenticator(settings, fetcher.fetch, () => nowMilliseconds);
  const error = await assertRejects(
    async () => verifier.verify(`Bearer ${await signedJwt(key, claims)}`),
    AgentError,
  );
  assertEquals(error.code, "upstream_error");
});
