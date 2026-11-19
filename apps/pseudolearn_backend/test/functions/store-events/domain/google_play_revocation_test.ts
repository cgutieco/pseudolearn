import { assertEquals } from "@std/assert";
import { googlePlayRevocationOf } from "../../../../supabase/functions/store-events/domain/google_play_revocation.ts";

Deno.test("revocations target the whole subscription or the single top-up", () => {
  assertEquals(googlePlayRevocationOf("t", true), {
    kind: "revocation",
    revocation: { store: "google_play", transactionId: null, originalTransactionId: "t" },
  });
  assertEquals(googlePlayRevocationOf("t", false), {
    kind: "revocation",
    revocation: {
      store: "google_play",
      transactionId: "google_play:t",
      originalTransactionId: null,
    },
  });
});
