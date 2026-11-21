const algorithm = { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" };

export interface GoogleTestKey {
  readonly kid: string;
  readonly privateKey: CryptoKey;
  readonly publicKey: CryptoKey;
  readonly privateKeyPem: string;
  readonly publicJwk: JsonWebKey & { kid: string };
}

export async function googleTestKey(kid = "key-1"): Promise<GoogleTestKey> {
  const pair = await crypto.subtle.generateKey(
    { ...algorithm, modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]) },
    true,
    ["sign", "verify"],
  );
  const pkcs8 = new Uint8Array(await crypto.subtle.exportKey("pkcs8", pair.privateKey));
  const body = btoa(String.fromCharCode(...pkcs8)).replace(/(.{64})/g, "$1\n");
  return {
    kid,
    privateKey: pair.privateKey,
    publicKey: pair.publicKey,
    privateKeyPem: `-----BEGIN PRIVATE KEY-----\n${body}\n-----END PRIVATE KEY-----\n`,
    publicJwk: { ...(await crypto.subtle.exportKey("jwk", pair.publicKey)), kid },
  };
}

export function base64UrlOf(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes)).replaceAll("+", "-").replaceAll("/", "_")
    .replaceAll("=", "");
}

function textSegment(value: unknown): string {
  return base64UrlOf(new TextEncoder().encode(JSON.stringify(value)));
}

export async function signedJwt(
  key: GoogleTestKey,
  claims: Record<string, unknown>,
  header: Record<string, unknown> = { alg: "RS256", kid: key.kid, typ: "JWT" },
): Promise<string> {
  const input = `${textSegment(header)}.${textSegment(claims)}`;
  const signature = await crypto.subtle.sign(
    algorithm,
    key.privateKey,
    new TextEncoder().encode(input),
  );
  return `${input}.${base64UrlOf(new Uint8Array(signature))}`;
}

export function segmentsOf(jwt: string): {
  header: Record<string, unknown>;
  claims: Record<string, unknown>;
} {
  const [header, claims] = jwt.split(".").slice(0, 2).map((segment) =>
    JSON.parse(atob(segment.replaceAll("-", "+").replaceAll("_", "/")))
  );
  return { header, claims };
}

export function pubSubEnvelope(notification: unknown): string {
  const data = btoa(JSON.stringify(notification));
  return JSON.stringify({
    message: { data, messageId: "1", attributes: {} },
    subscription: "projects/pseudolearn/subscriptions/play",
  });
}
