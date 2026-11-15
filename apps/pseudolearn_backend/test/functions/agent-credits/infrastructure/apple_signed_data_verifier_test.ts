import { assertEquals, assertRejects } from "@std/assert";
import { AppleSignedDataVerifier } from "../../../../supabase/functions/agent-credits/infrastructure/apple_signed_data_verifier.ts";
import { SignedDataError } from "../../../../supabase/functions/agent-credits/infrastructure/der_reader.ts";
import {
  certificateBase64,
  signJws,
  subscriptionTransaction,
  testNow,
  testRoot,
} from "../../../support/app_store_signing.ts";

const verifier = new AppleSignedDataVerifier({ trustedRoots: [testRoot], now: () => testNow });

async function failure(jws: string, target = verifier): Promise<string> {
  const error = await assertRejects(() => target.payloadOf(jws), SignedDataError);
  return error.message;
}

Deno.test("a JWS signed through a trusted chain yields its payload", async () => {
  const payload = await verifier.payloadOf(await signJws(subscriptionTransaction()));
  assertEquals(payload.originalTransactionId, "2000000000");
});

Deno.test("the real Apple root is the default and rejects the test chain", async () => {
  const production = new AppleSignedDataVerifier({ now: () => testNow });
  assertEquals(await failure(await signJws(subscriptionTransaction()), production), "chain_root");
});

Deno.test("a leaf without the Apple receipt marker is rejected", async () => {
  const chain = [
    certificateBase64("leaf-without-marker.pem"),
    certificateBase64("intermediate.pem"),
    testRoot,
  ];
  assertEquals(await failure(await signJws(subscriptionTransaction(), chain)), "chain_leaf_marker");
});

Deno.test("an intermediate without the Apple marker is rejected", async () => {
  const chain = [certificateBase64("leaf.pem"), testRoot, testRoot];
  assertEquals(
    await failure(await signJws(subscriptionTransaction(), chain)),
    "chain_intermediate_marker",
  );
});

Deno.test("a tampered payload breaks the signature", async () => {
  const [header, , signature] = (await signJws(subscriptionTransaction())).split(".");
  const forged = btoa(JSON.stringify(subscriptionTransaction({ productId: "x" })))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  assertEquals(await failure(`${header}.${forged}.${signature}`), "jws_signature");
});

Deno.test("certificates outside their validity are rejected", async () => {
  const late = new AppleSignedDataVerifier({
    trustedRoots: [testRoot],
    now: () => Date.UTC(2090, 0, 1),
  });
  assertEquals(await failure(await signJws(subscriptionTransaction()), late), "chain_validity");
});

Deno.test("malformed tokens and incomplete chains are rejected", async () => {
  assertEquals(await failure("not-a-jws"), "jws_format");
  assertEquals(await failure("a.b.c"), "jws_base64");
  assertEquals(await failure("bm9wZQ.e30.sig"), "jws_json");
  assertEquals(await failure(await signJws(subscriptionTransaction(), [testRoot])), "chain_length");
  const header = btoa(JSON.stringify({ alg: "RS256", x5c: [] }));
  assertEquals(await failure(`${header}.e30.sig`), "jws_header");
  const badCertificate = btoa(JSON.stringify({ alg: "ES256", x5c: ["AAAA"] }));
  assertEquals(await failure(`${badCertificate}.e30.sig`), "x509_structure");
  const truncated = btoa(JSON.stringify({ alg: "ES256", x5c: ["MBA="] }));
  assertEquals(await failure(`${truncated}.e30.sig`), "der_truncated");
});
