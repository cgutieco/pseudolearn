import { AgentError } from "../../agent-responses/domain/agent_error.ts";
import { isRecord } from "../../agent-responses/domain/credits.ts";
import type { Fetcher } from "../../agent-responses/infrastructure/fetcher.ts";
import {
  encodeBase64Url,
  encodeBase64UrlText,
} from "../../delete-account/infrastructure/base64url.ts";

export interface GoogleServiceAccount {
  readonly clientEmail: string;
  readonly privateKeyPem: string;
}

export const googleTokenEndpoint = "https://oauth2.googleapis.com/token";
export const androidPublisherScope = "https://www.googleapis.com/auth/androidpublisher";

const assertionLifetimeSeconds = 3_600;
const refreshMarginSeconds = 300;
const millisecondsPerSecond = 1_000;

export function googleServiceAccountOf(json: string): GoogleServiceAccount | null {
  try {
    const parsed: unknown = JSON.parse(json);
    if (!isRecord(parsed)) return null;
    const { client_email: clientEmail, private_key: privateKeyPem } = parsed;
    if (typeof clientEmail !== "string" || typeof privateKeyPem !== "string") return null;
    return clientEmail.length > 0 && privateKeyPem.length > 0
      ? { clientEmail, privateKeyPem }
      : null;
  } catch {
    return null;
  }
}

export class GoogleAccessTokens {
  private cached: { readonly token: string; readonly expiresAtSeconds: number } | null = null;

  constructor(
    private readonly account: GoogleServiceAccount,
    private readonly fetcher: Fetcher,
    private readonly now: () => number = Date.now,
  ) {}

  async token(): Promise<string> {
    const nowSeconds = Math.floor(this.now() / millisecondsPerSecond);
    if (this.cached !== null && this.cached.expiresAtSeconds - refreshMarginSeconds > nowSeconds) {
      return this.cached.token;
    }
    const response = await this.fetcher(googleTokenEndpoint, {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: await this.assertion(nowSeconds),
      }).toString(),
    });
    const body: unknown = response.ok ? await response.json() : null;
    if (!isRecord(body) || typeof body.access_token !== "string") {
      throw new AgentError("upstream_error", "google_token");
    }
    const lifetime = typeof body.expires_in === "number" ? body.expires_in : 0;
    this.cached = { token: body.access_token, expiresAtSeconds: nowSeconds + lifetime };
    return body.access_token;
  }

  private async assertion(issuedAtSeconds: number): Promise<string> {
    const header = encodeBase64UrlText(JSON.stringify({ alg: "RS256", typ: "JWT" }));
    const claims = encodeBase64UrlText(JSON.stringify({
      iss: this.account.clientEmail,
      scope: androidPublisherScope,
      aud: googleTokenEndpoint,
      iat: issuedAtSeconds,
      exp: issuedAtSeconds + assertionLifetimeSeconds,
    }));
    const signingInput = `${header}.${claims}`;
    const key = await importRsaPrivateKey(this.account.privateKeyPem);
    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      new TextEncoder().encode(signingInput),
    );
    return `${signingInput}.${encodeBase64Url(new Uint8Array(signature))}`;
  }
}

function importRsaPrivateKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll("\\n", "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(body), (character) => character.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}
