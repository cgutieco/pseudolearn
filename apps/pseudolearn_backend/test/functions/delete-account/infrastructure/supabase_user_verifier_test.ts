import { assertEquals, assertRejects } from "@std/assert";
import {
  accountUserFrom,
  SupabaseUserVerifier,
} from "../../../../supabase/functions/delete-account/infrastructure/supabase_user_verifier.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";

function verifier(fetcher: FakeFetcher) {
  return new SupabaseUserVerifier({
    supabaseUrl: "https://project.supabase.co",
    secretKey: "sb_secret_test",
    fetcher: fetcher.fetch,
  });
}

Deno.test("verifies the user token against Auth with the secret key on the apikey header", async () => {
  const fetcher = new FakeFetcher(() => Response.json({ id: "user-1", identities: [] }));

  const user = await verifier(fetcher).verify("user-jwt");

  assertEquals(user, { id: "user-1", appleSubject: null });
  const request = fetcher.requests[0];
  assertEquals(request.url, "https://project.supabase.co/auth/v1/user");
  assertEquals(request.headers.get("apikey"), "sb_secret_test");
  assertEquals(request.headers.get("authorization"), "Bearer user-jwt");
});

Deno.test("rejected tokens return null", async () => {
  for (const status of [401, 403, 404, 500]) {
    const fetcher = new FakeFetcher(() => Response.json({ msg: "bad" }, { status }));
    assertEquals(await verifier(fetcher).verify("user-jwt"), null);
  }
});

Deno.test("network failures propagate so the handler reports unexpected_failure", async () => {
  const fetcher = new FakeFetcher(() => Promise.reject(new TypeError("offline")));

  await assertRejects(() => verifier(fetcher).verify("user-jwt"));
});

Deno.test("extracts the Apple subject from identity data", () => {
  const user = accountUserFrom({
    id: "user-1",
    identities: [
      { provider: "google", identity_data: { sub: "google-sub" } },
      { provider: "apple", identity_data: { sub: "apple-sub" }, provider_id: "ignored" },
    ],
  });

  assertEquals(user, { id: "user-1", appleSubject: "apple-sub" });
});

Deno.test("falls back to provider_id and then id when identity data lacks the subject", () => {
  assertEquals(
    accountUserFrom({ id: "u", identities: [{ provider: "apple", provider_id: "pid" }] }),
    { id: "u", appleSubject: "pid" },
  );
  assertEquals(
    accountUserFrom({ id: "u", identities: [{ provider: "apple", id: "legacy-id" }] }),
    { id: "u", appleSubject: "legacy-id" },
  );
});

Deno.test("malformed users and identities are handled without throwing", () => {
  assertEquals(accountUserFrom(null), null);
  assertEquals(accountUserFrom([]), null);
  assertEquals(accountUserFrom({ id: "" }), null);
  assertEquals(accountUserFrom({ id: 5 }), null);
  assertEquals(accountUserFrom({ id: "u", identities: "apple" }), { id: "u", appleSubject: null });
  assertEquals(
    accountUserFrom({
      id: "u",
      identities: [null, { provider: "apple", identity_data: { sub: "" } }],
    }),
    { id: "u", appleSubject: null },
  );
});
