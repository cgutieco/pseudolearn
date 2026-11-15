import { assertEquals } from "@std/assert";
import type { DeletionOutcome } from "../../../../supabase/functions/delete-account/domain/deletion_outcome.ts";
import { createDeleteAccountHandler } from "../../../../supabase/functions/delete-account/http/delete_account_handler.ts";
import {
  CallLog,
  FakeAppleTokenClient,
  FakeUserDeleter,
  FakeUserVerifier,
} from "../../../support/fake_ports.ts";

function post(body?: string): Request {
  return new Request("https://example.test", {
    method: "POST",
    headers: { authorization: "Bearer jwt" },
    body,
  });
}

function dependencies(log: CallLog) {
  return {
    userVerifier: new FakeUserVerifier(log, { id: "user-1", appleSubject: null }),
    appleTokenClient: new FakeAppleTokenClient(log),
    userDeleter: new FakeUserDeleter(log),
  };
}

Deno.test("deletes the account and records the outcome", async () => {
  const recorded: DeletionOutcome[] = [];
  const handler = createDeleteAccountHandler(dependencies(new CallLog()), (outcome) => {
    recorded.push(outcome);
  });

  const response = await handler(post());

  assertEquals(response.status, 200);
  assertEquals(recorded, [{ kind: "deleted" }]);
});

Deno.test("rejected requests never reach the application", async () => {
  const log = new CallLog();
  const handler = createDeleteAccountHandler(dependencies(log), () => {});

  const response = await handler(post("{"));

  assertEquals(response.status, 400);
  assertEquals(log.calls, []);
});

Deno.test("missing environment answers misconfigured after validating the request", async () => {
  const handler = createDeleteAccountHandler(null, () => {});

  assertEquals((await handler(post())).status, 500);
  assertEquals((await handler(new Request("https://example.test"))).status, 405);
});

Deno.test("an adapter exception is contained as unexpected_failure", async () => {
  const recorded: DeletionOutcome[] = [];
  const failing = {
    ...dependencies(new CallLog()),
    userVerifier: { verify: () => Promise.reject(new Error("network down")) },
  };
  const handler = createDeleteAccountHandler(failing, (outcome) => {
    recorded.push(outcome);
  });

  const response = await handler(post());

  assertEquals(response.status, 500);
  assertEquals(await response.json(), { code: "unexpected_failure" });
  assertEquals(recorded, [{ kind: "failed", code: "unexpected_failure" }]);
});
