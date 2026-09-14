import { encodeBase64Url, encodeBase64UrlText } from "./base64url";
import type { AppleConfiguration } from "./environment.ts";

export const appleAudience = "https://appleid.apple.com";
export const clientSecretLifetimeSeconds = 300;

export async function createAppleClientSecret(
  configuration: AppleConfiguration,
  issuedAtSeconds: number,
): Promise<string> {
  const header = { alg: "ES256", kid: configuration.keyId, typ: "JWT" };
  const claims = {
    iss: configuration.teamId,
    iat: issuedAtSeconds,
    exp: issuedAtSeconds + clientSecretLifetimeSeconds,
    aud: appleAudience,
    sub: configuration.clientId,
  };
  const signingInput = `${encodeBase64UrlText(JSON.stringify(header))}.${
    encodeBase64UrlText(JSON.stringify(claims))
  }`;
  const key = await importPrivateKey(configuration.privateKeyPem);
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput),
  );
  return `${signingInput}.${encodeBase64Url(new Uint8Array(signature))}`;
}

function importPrivateKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll("\\n", "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(body), (character) => character.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
}
