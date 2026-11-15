import { assertEquals, assertRejects } from "@std/assert";
import {
  appleAudience,
  clientSecretLifetimeSeconds,
  createAppleClientSecret,
} from "../../../../supabase/functions/delete-account/infrastructure/apple_client_secret.ts";
import { decodeBase64UrlText } from "../../../../supabase/functions/delete-account/infrastructure/base64url.ts";
import type { AppleConfiguration } from "../../../../supabase/functions/delete-account/infrastructure/environment.ts";

async function generateKeyPair(): Promise<{ pem: string; publicKey: CryptoKey }> {
  const pair = await crypto.subtle.generateKey({ name: "ECDSA", namedCurve: "P-256" }, true, [
    "sign",
    "verify",
  ]);
  const der = new Uint8Array(await crypto.subtle.exportKey("pkcs8", pair.privateKey));
  const base64 = btoa(String.fromCharCode(...der));
  const lines = base64.match(/.{1,64}/g) ?? [];
  const pem = ["-----BEGIN PRIVATE KEY-----", ...lines, "-----END PRIVATE KEY-----"].join("\n");
  return { pem, publicKey: pair.publicKey };
}

function configuration(privateKeyPem: string): AppleConfiguration {
  return {
    teamId: "TEAM123456",
    keyId: "KEY1234567",
    clientId: "com.pseudolearn.app",
    privateKeyPem,
  };
}

function base64UrlBytes(segment: string): Uint8Array<ArrayBuffer> {
  const padded = segment.replaceAll("-", "+").replaceAll("_", "/")
    .padEnd(Math.ceil(segment.length / 4) * 4, "=");
  return Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
}

Deno.test("client secret carries Apple's required header and claims", async () => {
  const { pem } = await generateKeyPair();

  const secret = await createAppleClientSecret(configuration(pem), 1_800_000_000);
  const [header, claims] = secret.split(".").slice(0, 2).map((segment) =>
    JSON.parse(decodeBase64UrlText(segment) ?? "null")
  );

  assertEquals(header, { alg: "ES256", kid: "KEY1234567", typ: "JWT" });
  assertEquals(claims, {
    iss: "TEAM123456",
    iat: 1_800_000_000,
    exp: 1_800_000_000 + clientSecretLifetimeSeconds,
    aud: appleAudience,
    sub: "com.pseudolearn.app",
  });
});

Deno.test("client secret signature verifies with the matching public key", async () => {
  const { pem, publicKey } = await generateKeyPair();

  const secret = await createAppleClientSecret(configuration(pem), 1_800_000_000);
  const [header, claims, signature] = secret.split(".");
  const valid = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    publicKey,
    base64UrlBytes(signature),
    new TextEncoder().encode(`${header}.${claims}`),
  );

  assertEquals(valid, true);
  assertEquals(base64UrlBytes(signature).length, 64);
});

Deno.test("lifetime stays far below Apple's six month maximum", () => {
  assertEquals(clientSecretLifetimeSeconds > 0 && clientSecretLifetimeSeconds <= 15_777_000, true);
});

Deno.test("accepts a PEM stored with escaped newlines", async () => {
  const { pem } = await generateKeyPair();

  const secret = await createAppleClientSecret(configuration(pem.replaceAll("\n", "\\n")), 1);

  assertEquals(secret.split(".").length, 3);
});

Deno.test("rejects a malformed private key", async () => {
  await assertRejects(() =>
    createAppleClientSecret(
      configuration("-----BEGIN PRIVATE KEY-----\nAAAA\n-----END PRIVATE KEY-----"),
      1,
    )
  );
});
