import { assertEquals } from "@std/assert";
import { SupabaseUserDeleter } from "../../../../supabase/functions/delete-account/infrastructure/supabase_user_deleter.ts";
import { FakeFetcher } from "../../../support/fake_fetcher.ts";

function deleter(fetcher: FakeFetcher) {
  return new SupabaseUserDeleter({
    supabaseUrl: "https://project.supabase.co",
    secretKey: "sb_secret_test",
    fetcher: fetcher.fetch,
  });
}

Deno.test("hard deletes the user through the admin endpoint with the secret key only", async () => {
  const fetcher = new FakeFetcher(() => Response.json({}));

  const deleted = await deleter(fetcher).delete("user/1");

  assertEquals(deleted, true);
  const request = fetcher.requests[0];
  assertEquals(request.method, "DELETE");
  assertEquals(request.url, "https://project.supabase.co/auth/v1/admin/users/user%2F1");
  assertEquals(request.headers.get("apikey"), "sb_secret_test");
  assertEquals(request.headers.get("authorization"), null);
  assertEquals(JSON.parse(request.body), { should_soft_delete: false });
});

Deno.test("any non-2xx answer, including 404, is a failed deletion", async () => {
  for (const status of [400, 401, 403, 404, 500]) {
    const fetcher = new FakeFetcher(() => Response.json({ msg: "no" }, { status }));
    assertEquals(await deleter(fetcher).delete("user-1"), false);
  }
});

Deno.test("network failure is a failed deletion", async () => {
  const fetcher = new FakeFetcher(() => Promise.reject(new TypeError("offline")));

  assertEquals(await deleter(fetcher).delete("user-1"), false);
});
