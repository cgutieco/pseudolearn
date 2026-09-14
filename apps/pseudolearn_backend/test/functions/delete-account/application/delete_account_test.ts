import { assertEquals } from "@std/assert";
import {
  deleteAccount,
  type DeleteAccountCommand,
} from "../../../../supabase/functions/delete-account/application/delete_account";
import {
  CallLog,
  FakeAppleTokenClient,
  FakeUserDeleter,
  FakeUserVerifier,
} from "../../../support/fake_ports";

function scenario(appleSubject: string | null) {
  const log = new CallLog();
  const verifier = new FakeUserVerifier(log, { id: "user-1", appleSubject });
  const apple = new FakeAppleTokenClient(log);
  const deleter = new FakeUserDeleter(log);
  return {
    log,
    verifier,
    apple,
    deleter,
    dependencies: { userVerifier: verifier, appleTokenClient: apple, userDeleter: deleter },
  };
}

const googleCommand: DeleteAccountCommand = { accessToken: "jwt", appleAuthorizationCode: null };
const appleCommand: DeleteAccountCommand = { accessToken: "jwt", appleAuthorizationCode: "code" };

Deno.test("non-Apple account is deleted without contacting Apple", async () => {
  const { log, dependencies } = scenario(null);

  const outcome = await deleteAccount(googleCommand, dependencies);

  assertEquals(outcome, { kind: "deleted" });
  assertEquals(log.calls, ["verify:jwt", "delete:user-1"]);
});

Deno.test("non-Apple account ignores an unexpected Apple code", async () => {
  const { log, dependencies } = scenario(null);

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "deleted" });
  assertEquals(log.calls, ["verify:jwt", "delete:user-1"]);
});

Deno.test("Apple account exchanges, revokes and then deletes, in that order", async () => {
  const { log, dependencies } = scenario("apple-subject");

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "deleted" });
  assertEquals(log.calls, [
    "verify:jwt",
    "exchange:code",
    "revoke:refresh_token:apple-refresh-token",
    "delete:user-1",
  ]);
});

Deno.test("invalid session is unauthorized and touches nothing else", async () => {
  const { log, verifier, dependencies } = scenario(null);
  verifier.user = null;

  const outcome = await deleteAccount(googleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "unauthorized" });
  assertEquals(log.calls, ["verify:jwt"]);
});

Deno.test("Apple account without a fresh code requires re-authentication", async () => {
  const { log, dependencies } = scenario("apple-subject");

  const outcome = await deleteAccount(googleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "apple_reauthentication_required" });
  assertEquals(log.calls, ["verify:jwt"]);
});

Deno.test("Apple account without Apple configuration is misconfigured", async () => {
  const { log, dependencies } = scenario("apple-subject");

  const outcome = await deleteAccount(appleCommand, { ...dependencies, appleTokenClient: null });

  assertEquals(outcome, { kind: "failed", code: "misconfigured" });
  assertEquals(log.calls, ["verify:jwt"]);
});

Deno.test("failed code exchange stops before revoking or deleting", async () => {
  const { log, apple, dependencies } = scenario("apple-subject");
  apple.exchangeResult = { kind: "failed" };

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "apple_token_exchange_failed" });
  assertEquals(log.calls, ["verify:jwt", "exchange:code"]);
});

Deno.test("code from a different Apple ID is rejected without revoking that Apple ID", async () => {
  const { log, apple, dependencies } = scenario("apple-subject");
  apple.exchangeResult = {
    kind: "exchanged",
    subject: "another-apple-subject",
    token: { value: "other", hint: "refresh_token" },
  };

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "apple_identity_mismatch" });
  assertEquals(log.calls, ["verify:jwt", "exchange:code"]);
});

Deno.test("failed revocation keeps the account", async () => {
  const { log, apple, dependencies } = scenario("apple-subject");
  apple.revokeResult = false;

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "apple_revoke_failed" });
  assertEquals(log.calls.includes("delete:user-1"), false);
});

Deno.test("failed user deletion after revocation is reported as delete_failed", async () => {
  const { deleter, dependencies } = scenario("apple-subject");
  deleter.result = false;

  const outcome = await deleteAccount(appleCommand, dependencies);

  assertEquals(outcome, { kind: "failed", code: "delete_failed" });
});

Deno.test("retry after a failed deletion revokes the fresh code and deletes", async () => {
  const { log, deleter, dependencies } = scenario("apple-subject");
  deleter.result = false;
  await deleteAccount(appleCommand, dependencies);
  deleter.result = true;

  const outcome = await deleteAccount(
    { ...appleCommand, appleAuthorizationCode: "code-2" },
    dependencies,
  );

  assertEquals(outcome, { kind: "deleted" });
  assertEquals(log.calls.filter((call) => call.startsWith("revoke:")).length, 2);
});
