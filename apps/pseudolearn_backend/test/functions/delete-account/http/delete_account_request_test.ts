import { assertEquals } from "@std/assert";
import { parseDeleteAccountRequest } from "../../../../supabase/functions/delete-account/http/delete_account_request.ts";

function request(init: { method?: string; authorization?: string | null; body?: string }): Request {
  const headers = new Headers();
  if (init.authorization !== null) headers.set("authorization", init.authorization ?? "Bearer jwt");
  return new Request("https://example.test/functions/v1/delete-account", {
    method: init.method ?? "POST",
    headers,
    body: init.body,
  });
}

Deno.test("accepts an empty body as a request without Apple code", async () => {
  const parsed = await parseDeleteAccountRequest(request({}));

  assertEquals(parsed, {
    kind: "accepted",
    command: { accessToken: "jwt", appleAuthorizationCode: null },
  });
});

Deno.test("accepts and trims the Apple authorization code", async () => {
  const parsed = await parseDeleteAccountRequest(
    request({ body: JSON.stringify({ apple_authorization_code: "  code  " }) }),
  );

  assertEquals(parsed, {
    kind: "accepted",
    command: { accessToken: "jwt", appleAuthorizationCode: "code" },
  });
});

Deno.test("treats an explicit null Apple code as absent", async () => {
  const parsed = await parseDeleteAccountRequest(
    request({ body: JSON.stringify({ apple_authorization_code: null }) }),
  );

  assertEquals(parsed.kind, "accepted");
});

Deno.test("rejects methods other than POST", async () => {
  for (const method of ["GET", "PUT", "DELETE", "OPTIONS"]) {
    const parsed = await parseDeleteAccountRequest(request({ method }));
    assertEquals(parsed, { kind: "rejected", code: "method_not_allowed" });
  }
});

Deno.test("rejects missing or malformed bearer tokens", async () => {
  for (const authorization of [null, "", "Bearer", "Bearer ", "Basic jwt", "Bearer a b"]) {
    const parsed = await parseDeleteAccountRequest(request({ authorization }));
    assertEquals(parsed, { kind: "rejected", code: "unauthorized" });
  }
});

Deno.test("accepts a case-insensitive bearer scheme", async () => {
  const parsed = await parseDeleteAccountRequest(request({ authorization: "bearer jwt" }));

  assertEquals(parsed.kind, "accepted");
});

Deno.test("rejects bodies that are not a JSON object or carry an invalid code", async () => {
  for (
    const body of [
      "{",
      "[]",
      '"text"',
      "42",
      JSON.stringify({ apple_authorization_code: "" }),
      JSON.stringify({ apple_authorization_code: "   " }),
      JSON.stringify({ apple_authorization_code: 7 }),
    ]
  ) {
    const parsed = await parseDeleteAccountRequest(request({ body }));
    assertEquals(parsed, { kind: "rejected", code: "invalid_body" }, body);
  }
});
