const fixtureDirectory = new URL("../fixtures/app_store/", import.meta.url);

function fixture(name: string): string {
  return Deno.readTextFileSync(new URL(name, fixtureDirectory));
}

export function certificateBase64(name: string): string {
  return fixture(name).replace(/-----(BEGIN|END) CERTIFICATE-----/g, "").replace(/\s+/g, "");
}

export const testRoot = certificateBase64("root.pem");
export const testChain = [
  certificateBase64("leaf.pem"),
  certificateBase64("intermediate.pem"),
  testRoot,
];

function base64Url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(
    /=+$/,
    "",
  );
}

function textBase64Url(text: string): string {
  return base64Url(new TextEncoder().encode(text));
}

async function signingKey(): Promise<CryptoKey> {
  const pem = fixture("leaf.pkcs8.pem").replace(/-----(BEGIN|END) PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (character) => character.charCodeAt(0));
  return await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    [
      "sign",
    ],
  );
}

export async function signJws(
  payload: Record<string, unknown>,
  chain: string[] = testChain,
): Promise<string> {
  const header = textBase64Url(JSON.stringify({ alg: "ES256", x5c: chain }));
  const body = textBase64Url(JSON.stringify(payload));
  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    await signingKey(),
    new TextEncoder().encode(`${header}.${body}`),
  );
  return `${header}.${body}.${base64Url(new Uint8Array(signature))}`;
}

export const testNow = Date.UTC(2026, 10, 9, 12);
const day = 86_400_000;

export const appStoreCatalog = {
  bundleId: "com.pseudolearn.app",
  environments: new Set(["Production", "Sandbox"]),
};

export function subscriptionTransaction(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    transactionId: "2000000001",
    originalTransactionId: "2000000000",
    bundleId: "com.pseudolearn.app",
    productId: "pseudolearn.nodo.monthly",
    environment: "Production",
    purchaseDate: testNow - day,
    expiresDate: testNow + 29 * day,
    appAccountToken: "user-1",
    ...overrides,
  };
}

export function topUpTransaction(overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    transactionId: "3000000001",
    originalTransactionId: "3000000001",
    bundleId: "com.pseudolearn.app",
    productId: "pseudolearn.nodo.topup150",
    environment: "Production",
    purchaseDate: testNow,
    appAccountToken: "user-1",
    ...overrides,
  };
}
