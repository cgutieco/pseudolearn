import { assertEquals } from "@std/assert";
import type { DeletionFailureCode } from "../../../../supabase/functions/delete-account/domain/deletion_outcome.ts";
import {
  responseFor,
  statusByFailureCode,
} from "../../../../supabase/functions/delete-account/http/delete_account_response.ts";

Deno.test("deleted outcome answers 200 with status deleted", async () => {
  const response = responseFor({ kind: "deleted" });

  assertEquals(response.status, 200);
  assertEquals(await response.json(), { status: "deleted" });
});

Deno.test("every failure code answers its declared status and echoes the code", async () => {
  const expected: Record<DeletionFailureCode, number> = {
    method_not_allowed: 405,
    invalid_body: 400,
    unauthorized: 401,
    apple_reauthentication_required: 409,
    apple_identity_mismatch: 403,
    apple_token_exchange_failed: 502,
    apple_revoke_failed: 502,
    delete_failed: 500,
    misconfigured: 500,
    unexpected_failure: 500,
  };
  assertEquals(statusByFailureCode, expected);
  for (const [code, status] of Object.entries(expected)) {
    const response = responseFor({ kind: "failed", code: code as DeletionFailureCode });
    assertEquals(response.status, status);
    assertEquals(await response.json(), { code });
  }
});
